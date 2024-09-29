from fastapi import FastAPI
import platform
from prometheus_client import make_asgi_app
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)
Instrumentator().instrument(app).expose(app)

@app.get("/")
async def root():
    return {"message": "Hello from fastapi", "version": "0.0.3", "uname": platform.uname()}

@app.get("/items")
async def list_items():
    return {"items": ["item1", "item2", "item3"]}