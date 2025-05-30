# -*- coding: utf-8 -*-
"""cooccurrencegeneration.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1h9p5J9yWc7sJl-uVQFbbT3I1nV0pw4ht
"""

import json
import itertools
from collections import defaultdict
import numpy as np
import pandas as pd

with open("train.json", "r", encoding="utf-8") as f:
    data = json.load(f)

ingredient_to_idx = {}
for recipe in data:
    for raw in recipe["ingredients"]:
        ing = raw.strip().lower()
        if ing not in ingredient_to_idx:
            ingredient_to_idx[ing] = len(ingredient_to_idx)

n = len(ingredient_to_idx)
matrix = np.zeros((n, n), dtype=int)

for recipe in data:
    ing_set = {raw.strip().lower() for raw in recipe["ingredients"]}

    for a, b in itertools.combinations(ing_set, 2):
        i, j = ingredient_to_idx[a], ingredient_to_idx[b]
        matrix[i, j] += 1
        matrix[j, i] += 1

    for ing in ing_set:
        idx = ingredient_to_idx[ing]
        matrix[idx, idx] += 1 

from scipy import sparse
import numpy as np

mat_csr = sparse.csr_matrix(matrix)  
sparse.save_npz("cooc.npz", mat_csr, compressed=True)