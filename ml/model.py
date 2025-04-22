import sys
from typing import List
from PIL import Image
import torch
import clip
import numpy as np
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator
import matplotlib.pyplot as plt


device = "cuda" if torch.cuda.is_available() else "cpu"


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
        print("getting labels for image ", i)
        mask = seg["segmentation"]
        masked_img_np = img_np.copy()
        masked_img_np[~mask] = 0

        masked_pil = Image.fromarray(masked_img_np)
        label = classify_img(masked_pil, labels)
        seen_labels.add(label)

    return list(seen_labels)


# for testing
def show_segments(image_pil: Image.Image, masks: list[dict]):
    image_np = np.array(image_pil)

    plt.figure(figsize=(10, 10))
    plt.imshow(image_np)

    for mask in masks:
        plt.contour(mask["segmentation"], colors="red", linewidths=0.5)

    plt.axis("off")
    plt.title("All Segments")
    plt.show()


if __name__ == "__main__":
    img_path = sys.argv[1]
    im = Image.open(img_path).convert("RGB")

    segments = get_segments(im)
    show_segments(im, segments)  # for testing

    print("Number of segments: ", len(segments))

    labels = [
        "egg",
        "flour",
        "milk",
        "sugar",
        "chocolate chips",
        "vanilla extract",
        "brown sugar",
        "butter",
    ]

    img_np = np.array(im)
    ingredients = get_ingredients(img_np, segments, labels)

    print("Predicted ingredients:")
    for label in ingredients:
        print(f"  - {label}")
