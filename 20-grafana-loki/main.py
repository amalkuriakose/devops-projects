from fastapi import FastAPI
import platform
import logging
from prometheus_client import make_asgi_app
from prometheus_fastapi_instrumentator import Instrumentator

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

logger.debug("Starting")

app = FastAPI()
logger.debug("App Initialized")

metrics_app = make_asgi_app()
logger.debug("Metrics App Initialized")

app.mount("/metrics", metrics_app)
logger.debug("Metrics Mounted")

Instrumentator().instrument(app).expose(app)
logger.debug("Instrmentator Exposed")

@app.get("/")
async def root():
    logger.debug("At Root method")
    logger.info("Info Test")
    logger.warning("Warning Test")
    logger.error("Error Test")
    logger.critical("Critical Test")
    return {"message": "Hello from fastapi", "version": "0.0.3", "uname": platform.uname()}

@app.get("/items")
async def list_items():
    logger.debug("At List Items method")
    return {"items": ["item1", "item2", "item3"]}