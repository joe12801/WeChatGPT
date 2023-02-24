from fastapi import Depends, FastAPI
from fastapi.security.api_key import APIKey
from pydantic import BaseModel

import auth 
import subprocess

app = FastAPI()

class ChatAskRequest(BaseModel):
    prompt: str
    conversation: str

def chatgpt_ask(prompt, conversation):
    try:
        response = subprocess.check_output(f"python chat.py {prompt} {conversation}", shell=True, stderr=subprocess.STDOUT, timeout=360)
        resp_msg = response.decode(encoding='utf-8')
        return {"code": 200, "msg": "success", "response": resp_msg}
    except subprocess.CalledProcessError as e:
        out_bytes = e.output.decode()
        return {"code": e.returncode, "msg": out_bytes, "response": ""}

# Lockedown Route
@app.post("/chatgpt/ask")
async def ask(request: ChatAskRequest, api_key: APIKey = Depends(auth.get_api_key)):
    return chatgpt_ask(request.prompt, request.conversation)
