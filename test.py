import os
import google.generativeai as genai

# 1. Configure the API key (via environment variable or directly)
genai.configure(api_key=os.environ.get("GEMINI_API_KEY", "AIzaSyA39qRo8k2VY33xV7wyo06eE_9i4NGhKxA"))

# 2. Define generation settings
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

# 3. Create the model
model = genai.GenerativeModel(
    model_name="gemini-2.0-flash",
    generation_config=generation_config,
)

# 4. Start a chat session
chat_session = model.start_chat(
    history=[]  # or add messages if desired
)

# 5. Send a message
#response = chat_session.send_message("Hello! How are you today?")
response = chat_session.send_message("Ulaanbaatar weather?")
print(response.text)