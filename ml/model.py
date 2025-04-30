import sys
import json
import pickle
from pathlib import Path
from typing import List, Set

import numpy as np
from PIL import Image
import torch
import clip
from scipy import sparse
import matplotlib.pyplot as plt
from contextlib import nullcontext
from tqdm import tqdm

from segment_anything import sam_model_registry, SamAutomaticMaskGenerator

"""
Image‑labeling pipeline that combines:
  • Segment‑Anything (SAM) for mask proposal
  • OpenAI CLIP (ViT‑B/32) for zero‑shot label matching
  • Co‑occurrence PMI post‑filtering

Works on CUDA, Apple‑Silicon (MPS) or CPU‐only boxes.
For Macs running on MPS we keep CLIP on the GPU but force SAM to CPU to avoid
float64‑dtype limitations inside the automatic mask generator.
"""

# ============================================================
#                         CONFIG                              
# ============================================================
SRC_JSON       = Path("train.json")          # ingredient JSON
CACHE_PKL      = Path("labels.pkl")          # cached label list (always a **list**, never a dict from now on!)
TXT_EMB_NPY    = Path("label_emb.npy")       # cached CLIP text embeddings
COOC_NPZ       = Path("cooc.npz")            # sparse co‑occurrence counts
PPMI_NPY       = Path("ppmi.npy")            # cached PMI matrix
SAM_CHECKPOINT = "sam_vit_b_01ec64.pth"      # SAM checkpoint
MODEL_TYPE     = "vit_b"                     # SAM variant

# ============================================================
#                  DEVICE SELECTION (CLIP)                    
# ============================================================
if torch.cuda.is_available():
    DEVICE = "cuda"
elif torch.backends.mps.is_available():
    DEVICE = "mps"
else:
    DEVICE = "cpu"
print(f"[init] main device: {DEVICE}")

torch.set_float32_matmul_precision("high")

# autocast helper – fp16 only on CUDA
if DEVICE == "cuda":
    def _autocast():
        return torch.autocast(device_type="cuda", dtype=torch.float16)
else:
    def _autocast():
        return nullcontext()

# ============================================================
#                  LOAD CLIP  (zero‑shot)                     
# ============================================================
print("[init] loading CLIP ViT‑B/32 …")
CLIP_MODEL, CLIP_PREPROCESS = clip.load("ViT-B/32", device=DEVICE, jit=False)
CLIP_MODEL.eval(); CLIP_MODEL.requires_grad_(False)

# ============================================================
#              LOAD SAM  (mask generation)                    
# ============================================================
# SAM uses some float64 intermediate tensors → MPS kernel crash.
# Easiest workaround: keep SAM on CPU when running on Apple Silicon.
SAM_DEVICE = "cpu" if DEVICE == "mps" else DEVICE
print(f"[init] loading SAM ({SAM_DEVICE}) …")
SAM_MODEL = sam_model_registry[MODEL_TYPE](checkpoint=SAM_CHECKPOINT).to(SAM_DEVICE)
SAM_MASKGEN = SamAutomaticMaskGenerator(
    model=SAM_MODEL,
    points_per_side=16,
    pred_iou_thresh=0.88,
    stability_score_thresh=0.92,
    min_mask_region_area=4_000,
)

# ============================================================
#                        LABELS                               
# ============================================================

def _parse_labels() -> List[str]:
    """Extract unique, lower‑cased ingredient names from `train.json`."""
    with SRC_JSON.open("r", encoding="utf-8") as fh:
        data = json.load(fh)
    idx = {}
    for recipe in data:
        for raw in recipe.get("ingredients", []):
            ing = raw.strip().lower()
            idx.setdefault(ing, len(idx))
    return list(idx.keys())

# --- load / upgrade the cached label list -------------------
if CACHE_PKL.exists():
    loaded = pickle.loads(CACHE_PKL.read_bytes())

    # Legacy support: the very first version stored a **dict** name→index.
    if isinstance(loaded, dict):
        print("[init] detected legacy label cache (dict) → upgrading to list …")
        tmp = [None] * (max(loaded.values()) + 1)
        for name, pos in loaded.items():
            # Make sure we don’t accidentally extend beyond the declared size
            if pos >= len(tmp):
                tmp.extend([None] * (pos - len(tmp) + 1))
            tmp[pos] = name
        LABELS: List[str] = tmp
        # overwrite with the new, canonical format
        CACHE_PKL.write_bytes(pickle.dumps(LABELS, protocol=pickle.HIGHEST_PROTOCOL))
        print("[init] label cache upgraded and re‑saved")
    else:
        LABELS: List[str] = loaded  # already the right format
else:
    LABELS = _parse_labels()
    CACHE_PKL.write_bytes(pickle.dumps(LABELS, protocol=pickle.HIGHEST_PROTOCOL))
print(f"[init] {len(LABELS):,} unique labels")

# ============================================================
#              TEXT EMBEDDINGS  (cache)                       
# ============================================================
# If the label list length changes (e.g. after an upgrade), we MUST re‑encode
# the text prompts to keep everything in‑sync.
need_reencode = True
if TXT_EMB_NPY.exists():
    try:
        TEXT_EMB = torch.from_numpy(np.load(TXT_EMB_NPY)).float()
        if TEXT_EMB.shape[0] == len(LABELS):
            need_reencode = False
            print("[init] loaded cached text embeddings")
        else:
            print("[init] cached text embeddings out‑of‑date (size mismatch) → rebuilding …")
    except Exception:
        print("[init] failed to load cached text embeddings → rebuilding …")

if need_reencode:
    print("[init] encoding label texts … (one‑off)")
    batch = 256
    vecs = []
    for i in tqdm(range(0, len(LABELS), batch), "Encoding", leave=False):
        toks = clip.tokenize(LABELS[i:i+batch]).to(DEVICE)
        with _autocast():
            e = CLIP_MODEL.encode_text(toks).float()
        e /= e.norm(dim=-1, keepdim=True)
        vecs.append(e.cpu())
    TEXT_EMB = torch.cat(vecs)
    np.save(TXT_EMB_NPY, TEXT_EMB.numpy())
    print("[init] text embeddings cached → label_emb.npy")

# Fast name→index helper
IDX_OF = {lbl: i for i, lbl in enumerate(LABELS)}

# ============================================================
#                 PMI  (co‑occurrence filter)                 
# ============================================================

def _pmi_matrix(C: sparse.csr_matrix, eps: float = 1e-9) -> np.ndarray:
    """Compute PPMI (positive PMI) matrix from raw co‑occurrence counts."""
    N = C.sum()
    freq = np.asarray(C.sum(axis=1)).astype(float).reshape(-1, 1)
    expected = (freq @ freq.T) / N
    with np.errstate(divide="ignore"):
        pmi = np.log2((C.toarray() + eps) / (expected + eps))
    pmi[pmi < 0] = 0  # keep only positive PMI
    return pmi

if PPMI_NPY.exists():
    PPMI = np.load(PPMI_NPY)
    print("[init] loaded cached PMI matrix")
else:
    print("[init] computing PMI matrix … (one‑off slow step)")
    PPMI = _pmi_matrix(sparse.load_npz(COOC_NPZ).astype(float))
    np.save(PPMI_NPY, PPMI)

# ============================================================
#                    CORE  FUNCTIONS                          
# ============================================================

def _segment(img: Image.Image):
    """Return list of masks from SAM."""
    return SAM_MASKGEN.generate(np.array(img))


def _classify(img_np: np.ndarray, segs: List[dict]) -> Set[str]:
    """Run CLIP on each SAM‑proposed crop and return the top label for each."""
    if not segs:
        return set()

    crops = []
    for s in tqdm(segs, desc="Masks", leave=False):
        m = s["segmentation"]
        crop = img_np.copy(); crop[~m] = 0
        crops.append(CLIP_PREPROCESS(Image.fromarray(crop)))

    imgs = torch.stack(crops).to(DEVICE)
    with _autocast():
        emb = CLIP_MODEL.encode_image(imgs).float().cpu()
    emb /= emb.norm(dim=-1, keepdim=True)

    idx = (emb @ TEXT_EMB.T).argmax(dim=-1).tolist()
    return {LABELS[i] for i in idx}


def _filter(cands: Set[str], thresh: float = 0.5, links: int = 1) -> List[str]:
    """Simple PMI‑based post‑filtering: keep labels co‑occurring with ≥ `links` others."""
    kept = []
    idxs = [IDX_OF[c] for c in cands if c in IDX_OF]
    for c in tqdm(cands, desc="PMI", leave=False):
        i = IDX_OF.get(c)
        if i is None:
            continue
        strong = (PPMI[i, idxs] >= thresh).sum() - 1  # exclude self
        if strong >= links:
            kept.append(c)
    return kept

# ============================================================
#                     VISUALISATION                           
# ============================================================

def _show(image: Image.Image, masks: List[dict]):
    plt.figure(figsize=(8, 8))
    plt.imshow(np.array(image))
    for m in masks:
        plt.contour(m["segmentation"], colors="red", linewidths=0.4)
    plt.axis("off"); plt.title("SAM segments"); plt.show()

# ============================================================
#                           MAIN                              
# ============================================================

def process_image(path: str, viz: bool = False):
    print(f"[run] {path}")
    img = Image.open(path).convert("RGB")

    segs = _segment(img)
    if viz:
        _show(img, segs)

    cand = _classify(np.array(img), segs)
    print("    candidates:", sorted(cand))

    final = _filter(cand)
    print("    filtered:")
    for f in final:
        print(f"      • {f}")
    return final

# ============================================================
#                    CLI ENTRY‑POINT                          
# ============================================================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python model.py <image_path> [--viz]")
        sys.exit(1)
    img_p = sys.argv[1]
    viz = "--viz" in sys.argv
    process_image(img_p, viz=viz)
