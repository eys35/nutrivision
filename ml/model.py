import sys
from typing import List
from PIL import Image
import torch
import clip
from scipy import sparse
import numpy as np
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator
import matplotlib.pyplot as plt
import json, pickle, os
from pathlib import Path

SRC_JSON   = Path("train.json")       
CACHE_PKL  = Path("labels.pkl") 
device = "cuda" if torch.cuda.is_available() else "cpu"


def get_labels():
    with SRC_JSON.open("r", encoding="utf-8") as f:
        data = json.load(f)

    idx = {}
    for recipe in data:
        for raw in recipe["ingredients"]:
            ing = raw.strip().lower()
            idx.setdefault(ing, len(idx)) 
    return idx


def get_segments(pil_img: Image.Image) -> list[dict]:
    model_type = "vit_b"
    sam_checkpoint = "sam_vit_b_01ec64.pth"

    image_np = np.array(pil_img)

    sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
    sam.to(device)

    # mask_generator = SamAutomaticMaskGenerator(sam)
    mask_generator = SamAutomaticMaskGenerator(
        model=sam,
        points_per_side=16,
        pred_iou_thresh=0.88,
        stability_score_thresh=0.92,
        min_mask_region_area=4000,
    )

    masks = mask_generator.generate(image_np)
    return masks


def classify_img(pil_img: Image.Image, labels: List[str]) -> str:
    model, preprocess = clip.load("ViT-B/32", device=device)

    image = preprocess(pil_img).unsqueeze(0).to(device)
    text = clip.tokenize(labels).to(device)

    with torch.no_grad():
        logits_per_image, _ = model(image, text)
        probs = logits_per_image.softmax(dim=-1).cpu().numpy()

    return labels[np.argmax(probs)]


def get_ingredients(img_np, segments: list[dict], labels: List[str]) -> List[str]:

    seen_labels = set()

    for i, seg in enumerate(segments):
        # print("getting labels for image ", i)
        mask = seg["segmentation"]
        masked_img_np = img_np.copy()
        masked_img_np[~mask] = 0

        masked_pil = Image.fromarray(masked_img_np)
        label = classify_img(masked_pil, labels)
        seen_labels.add(label)

    return list(seen_labels)


def show_segments(image_pil: Image.Image, masks: list[dict]):
    image_np = np.array(image_pil)

    plt.figure(figsize=(10, 10))
    plt.imshow(image_np)

    for mask in masks:
        plt.contour(mask["segmentation"], colors="red", linewidths=0.5)

    plt.axis("off")
    plt.title("All Segments")
    plt.show()

def filter_ingredients(candidates, PPMI, idx_of,
                       thresh=0.5, min_links=1):
    """
    Keep only ingredients that have *at least `min_links`* other
    candidates with PPMI ≥ `thresh`.
    """
    keep = []
    for ing in candidates:
        i = idx_of.get(ing)
        if i is None:                  # unseen ingredient
            continue
        # Slice the row and pick scores against the other candidates
        partners = [idx_of[x] for x in candidates if x != ing and x in idx_of]
        strong = (PPMI[i, partners] >= thresh).sum()
        if strong >= min_links:
            keep.append(ing)
    return keep

def pmi_matrix(C, eps=1e-9):
    N = C.sum()
    freq = C.sum(axis=1, keepdims=True)               # column-vector
    expected = freq @ freq.T / N
    with np.errstate(divide="ignore"):
        pmi = np.log2((C + eps) / (expected + eps))
    pmi[pmi < 0] = 0                                   # positive PMI (PPMI)
    return pmi
    


def process_image(img_path):
    im = Image.open(img_path).convert("RGB")

    segments = get_segments(im)
    # show_segments(im, segments)  # for testing
    print("got segments")
    if CACHE_PKL.exists():
        with CACHE_PKL.open("rb") as f:
            labels = pickle.load(f)
    else:
        labels = get_labels()
        with CACHE_PKL.open("wb") as f:
            pickle.dump(labels, f, protocol=pickle.HIGHEST_PROTOCOL)

    img_np = np.array(im)
    ingredients = get_ingredients(img_np, segments, labels)
    print("got ingredients")
    mat_csr = sparse.load_npz("cooc.npz")
    print("decompressed matrix")
    PPMI = pmi_matrix(mat_csr.astype(float))
    print("made pmi matrix")

    idx_of = {ing: i for i, ing in enumerate(ingredients)}

    filtered_ingredients = filter_ingredients(ingredients, PPMI, idx_of, thresh = 0.5, min_links=1)
    
    print("Predicted ingredients:")
    for label in ingredients:
        print(f"  - {label}")
    
    return filtered_ingredients

process_image('test.jpeg')