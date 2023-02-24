from revChatGPT.V1 import Chatbot
import sys
import os

chatbot = Chatbot(config={
    "session_token": "<YOUR OPENCHAT SESSION TOKEN>"
})

prompt = sys.argv[1]
conversation = sys.argv[2]

conversation_id = None
filepath = f"./{conversation}.txt"
if os.path.exists(filepath):
    f = open(f"./{conversation}.txt", "r")
    conversation_id = f.read()

prev_text = ""
message = ""
for data in chatbot.ask(prompt, conversation_id, ):
    message = message + data["message"][len(prev_text) :]
    prev_text = data["message"]
    
    conversation_id = data["conversation_id"]
    f = open(filepath, "w")
    f.write(conversation_id)

print(message)
