from functools import lru_cache

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=True,
    )

    ENVIRONMENT: str = "development"
    SECRET_KEY: str = Field(..., min_length=16)
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    DATABASE_URL: str = Field(...)
    CORS_ORIGINS: str = "http://localhost:8000,http://127.0.0.1:8000"
    FIREBASE_CREDENTIALS_FILE: str | None = None
    FIREBASE_PROJECT_ID: str | None = None
    LOG_LEVEL: str = "INFO"
    APP_NAME: str = "MemoryGuide API"
    APP_VERSION: str = "1.0.0"

    @field_validator("ENVIRONMENT")
    @classmethod
    def normalize_environment(cls, value: str) -> str:
        return value.lower().strip()

    @field_validator("FIREBASE_CREDENTIALS_FILE", "FIREBASE_PROJECT_ID")
    @classmethod
    def empty_to_none(cls, value: str | None) -> str | None:
        if value is None:
            return None
        stripped = value.strip()
        return stripped or None

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"

    @property
    def is_test(self) -> bool:
        return self.ENVIRONMENT == "test"

    @property
    def firebase_enabled(self) -> bool:
        return bool(self.FIREBASE_CREDENTIALS_FILE)


@lru_cache
def get_settings() -> Settings:
    settings = Settings()
    insecure = {
        "changeme",
        "test-secret-key-for-tests-only",
        "dev-insecure-secret-change-me",
    }
    if settings.is_production and settings.SECRET_KEY in insecure:
        raise RuntimeError("Refusing to start with an insecure SECRET_KEY in production.")
    return settings
