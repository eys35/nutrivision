import requests
import time
import random
import json
import os
# Directory to store the outputs
output_dir = '/Users/elizabethsong/Desktop/nutrivision/nutrivision/ml/outputs'
os.makedirs(output_dir, exist_ok=True)

# Function to save request and response to a file
def save_request_response(request_data, response_data, index):
    output_file = os.path.join(output_dir, f'output_{index + 1}.json')
    with open(output_file, 'w') as file:
        json.dump({
            "request": request_data,
            "response": response_data
        }, file, indent=4)
# URL of the server endpoint
url = "http://localhost:5000/run_model"  # Update with the correct server URL if different

with open('/Users/elizabethsong/Desktop/nutrivision/nutrivision/ml/ingredients_list.txt', 'r') as file:
    ingredients = [line.strip() for line in file.readlines()]

possible_allergies = [
    "Peanuts", "Dairy", "Shellfish", "Gluten", 
    "Eggs", "Tree Nuts", "Wheat", "Soy", "Fish"
]

for i in range(10):
    random_ingredients = random.sample(ingredients, min(10, len(ingredients)))
    random_allergies = random.sample(possible_allergies, random.randint(0, len(possible_allergies)))
    payload = {
        "labels": random_ingredients,
        "allergies": random_allergies
    }
    try:
        response = requests.post(url, json=payload)
        if response.status_code == 200:
            print(f"Output {i + 1}: {response.json()}")
            save_request_response(payload, response.json(), i)
        else:
            print(f"Output {i + 1}: Request failed with status code {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Output {i + 1}: Request failed with exception {e}")
    time.sleep(1)