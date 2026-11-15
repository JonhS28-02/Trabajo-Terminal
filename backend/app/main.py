import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from .config import settings
from .routers.auth import router as auth_router
from .routers.especialista import catalogos_router, router as especialista_router
from .routers.evaluacion import router as evaluacion_router

limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])

app = FastAPI(
    title="Brain Test API",
    description="Backend para detección de deterioro cognitivo — TT 2026-B141, ESCOM-IPN",
    version="0.1.0",
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in settings.CORS_ORIGINS.split(",") if o.strip()],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(especialista_router)
app.include_router(catalogos_router)
app.include_router(evaluacion_router)


@app.on_event("startup")
def on_startup():
    from .seed_catalogos import seed
    seed()


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/modelo/info")
def modelo_info():
    from .services import prediccion
    return prediccion.info_modelo()


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logging.getLogger("uvicorn.error").exception("Error no controlado en %s %s", request.method, request.url.path)
    return JSONResponse(
        status_code=500,
        content={"detail": "Error interno del servidor"},
    )
