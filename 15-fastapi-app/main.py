from fastapi import FastAPI
import platform

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello from fastapi", "version": "0.0.3", "uname": platform.uname()}

@app.get("/items")
async def list_items():
    return {"items": ["item1", "item2", "item3"]}