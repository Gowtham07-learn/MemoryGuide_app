import logging

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

logger = logging.getLogger(__name__)

from app.api.v1.router import api_router
from app.core.config import get_settings
from app.core.exceptions import AppError
from app.core.logging import configure_logging
from app.db.session import SessionLocal
from app.schemas.common import ErrorBody, ErrorResponse

settings = get_settings()
configure_logging(settings.LOG_LEVEL)

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

app.include_router(api_router, prefix="/api/v1")


@app.get("/health")
def health() -> dict:
    return {"success": True, "data": {"status": "ok"}, "message": "Service is healthy"}


@app.get("/ready")
def ready() -> JSONResponse:
    try:
        db = SessionLocal()
        try:
            db.execute(text("SELECT 1"))
        finally:
            db.close()
        return JSONResponse(
            {"success": True, "data": {"status": "ready", "database": "connected"}, "message": "Ready"}
        )
    except SQLAlchemyError:
        return JSONResponse(
            status_code=503,
            content={
                "success": False,
                "error": {
                    "code": "DATABASE_UNAVAILABLE",
                    "message": "Database is not reachable",
                    "details": [],
                },
            },
        )


@app.exception_handler(AppError)
async def app_error_handler(_request: Request, exc: AppError) -> JSONResponse:
    body = ErrorResponse(error=ErrorBody(code=exc.code, message=exc.message, details=exc.details))
    return JSONResponse(status_code=exc.status_code, content=body.model_dump())


@app.exception_handler(RequestValidationError)
async def validation_handler(_request: Request, exc: RequestValidationError) -> JSONResponse:
    details = []
    for error in exc.errors():
        details.append({"loc": list(error.get("loc", [])), "msg": error.get("msg"), "type": error.get("type")})
    body = ErrorResponse(
        error=ErrorBody(code="VALIDATION_ERROR", message="Request validation failed", details=details)
    )
    return JSONResponse(status_code=422, content=body.model_dump())


@app.exception_handler(SQLAlchemyError)
async def database_handler(_request: Request, exc: SQLAlchemyError) -> JSONResponse:
    logger.exception("Database error: %s", exc)
    body = ErrorResponse(
        error=ErrorBody(code="DATABASE_ERROR", message="A database error occurred", details=[])
    )
    return JSONResponse(status_code=500, content=body.model_dump())
