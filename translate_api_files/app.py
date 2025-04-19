import ssl
import warnings
from flask import Flask, request, jsonify
import requests
import json
import os
from dotenv import load_dotenv
load_dotenv()


# Suppress warnings and set up SSL context
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)
ssl._create_default_https_context = ssl._create_unverified_context

# Initialize the Flask app
app = Flask(__name__)

# Replace this with your actual GROQ API key
GROQ_API_KEY = "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"  # Make sure to replace this with your actual key

# URL for the Groq API chat completions endpoint
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# Route for translation (English to Bengali)
@app.route("/translate", methods=["POST"])
def translate_text():
    data = request.json
    text_to_translate = data.get("text", "")
    
    # Check if the text is empty
    if not text_to_translate:
        return jsonify({"error": "No text provided"}), 400
    
    # Prepare the payload for the GROQ API request
    payload = {
        "model": "mistral-saba-24b",
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant that translates text from en to bn. You will only reply with the translation text and nothing else in JSON. The JSON object must use the schema: {\"translated_text\": \"string\"}"
            },
            {
                "role": "user",
                "content": f"Translate '{text_to_translate}' from en to bn."
            }
        ],
        "temperature": 0.2,
        "max_tokens": 1024,
        "stream": False,
        "response_format": {"type": "json_object"}
    }

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    # Send the request to GROQ API
    try:
        response = requests.post(GROQ_API_URL, json=payload, headers=headers)

        # Check if the request was successful
        if response.status_code == 200:
            response_data = response.json()
            choices = response_data.get("choices", [])
            if choices:
                content = choices[0].get("message", {}).get("content", "")
                try:
                    translated_data = json.loads(content)
                    translated_text = translated_data.get("translated_text", "")
                    return jsonify({
                        "original": text_to_translate,
                        "translated": translated_text
                    })
                except json.JSONDecodeError:
                    return jsonify({"error": "Failed to parse JSON response"}), 500
            else:
                return jsonify({"error": "No choices in response"}), 500
        else:
            return jsonify({"error": "Translation failed", "details": response.text}), 500

    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Request error", "details": str(e)}), 500

if __name__ == "__main__":
    # Run the Flask app
    port = int(os.environ.get("PORT", 5000))  # Default to port 5000
    app.run(host='0.0.0.0', port=port)