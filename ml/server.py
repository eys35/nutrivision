# server.py
from flask import Flask, request, jsonify
from model import process_image  # import your image handler
from PIL import Image
import io
import requests
import json
import google.generativeai as genai
LOCAL_API_KEY = "AIzaSyC83mzBWpxdcFKIOtGOwkch6vOrh1_MYmY"
genai.configure(api_key=LOCAL_API_KEY)
app = Flask(__name__)

@app.route('/segment_detect', methods=['POST'])
def segment_and_classify():
    print("📥 Received POST to /segment_detect")
    print("→ Files:", request.files)
    print("→ Form fields:", request.form)

    if 'file' not in request.files:
        print("❌ No file part in request.")
        return jsonify({'error': 'No file uploaded'}), 400

    file = request.files['file']
    print("📂 File received:", file.filename)

    try:
        img = Image.open(file.stream).convert("RGB")
        labels = process_image(file.stream, viz=False)
        print("✅ Processed image. Returning labels.")
        return jsonify(labels)
    except Exception as e:
        print("❌ Error during processing:", e)
        return jsonify({'error': str(e)}), 500
    
@app.route('/run_model', methods=['POST'])
def run_model():
    data = request.json
    labels = data.get("labels", [])
    allergies = data.get("allergies", [])
    print("📥 Received POST to /run_model")

    try:
        prompt = f"""
        Given the following ingredients: {', '.join(labels)},
        and allergies: {', '.join(allergies)},
        write a detailed recipe including:
        - A title (1 line)
        - A list of ingredients (with units if possible)
        - A list of step-by-step instructions
        - Estimated preparation time (in minutes)
        - Difficulty level (novice, intermediate, expert)
        - Number of servings

        Return it in this exact JSON format:
        {{
          "recipeName": "...",
          "ingredients": ["..."],
          "instructions": ["..."],
          "difficulty": "...",
          "preparationTime": ...,
          "servings": ...
        }}
        """
        # Debug: print the prompt being sent
        print("📝 Prompt sent to Gemini:\n", prompt)
        model = genai.GenerativeModel("gemini-2.0-flash-lite")
        response = model.generate_content(prompt)
        # Debug: print the raw response object and text
        print("📦 Raw Gemini response object:", response)
        print("📦 Raw Gemini response.text:", repr(response.text))

        if not response.text.strip():
            raise ValueError("Gemini returned an empty response.")
        
        print("🧠 Gemini raw output:", repr(response.text))
        raw_text = response.text.strip()
        if raw_text.startswith("```json"):
            raw_text = raw_text.removeprefix("```json").strip()
        if raw_text.endswith("```"):
            raw_text = raw_text.removesuffix("```").strip()

        generated_json = json.loads(raw_text)

        # ingredients_you_have = []
        # ingredients_to_buy = []

        # for item in generated_json["ingredients"]:
        #     if item.lower() in [label.lower() for label in labels]:
        #         ingredients_you_have.append(item)
        #     else:
        #         ingredients_to_buy.append(item)
        # print("🛒 Ingredients you have:", ingredients_you_have)
        
        return jsonify({
            "name": generated_json["recipeName"],
            "ingredients": generated_json["ingredients"],
            "userAllergies": allergies,
            "instructions": generated_json.get("instructions", []),
            "difficulty": generated_json.get("difficulty", ""),
            "preparationTime": generated_json.get("preparationTime", 0),
            "servings": generated_json.get("servings", 1)
        })
    
    except requests.exceptions.RequestException as e:
        print("❌ ChefGPT API error:", e)
        return jsonify({'error': str(e)}), 500
    except ValueError as e:
        print("❌ Gemini parsing error:", e)
        return jsonify({'error': 'Gemini returned invalid or empty JSON'}), 500
    
if __name__ == "__main__":
    app.run(debug=True)