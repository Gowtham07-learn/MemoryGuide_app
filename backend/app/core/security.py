from datetime import datetime, timedelta, timezone
from typing import Any
from uuid import UUID

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError, VerifyMismatchError

from app.core.config import get_settings
from app.core.exceptions import UnauthorizedError

_TEST_HASHER = PasswordHasher(time_cost=1, memory_cost=8, parallelism=1)
_DEFAULT_HASHER = PasswordHasher()


def _hasher() -> PasswordHasher:
    return _TEST_HASHER if get_settings().is_test else _DEFAULT_HASHER


def hash_password(password: str) -> str:
    return _hasher().hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _hasher().verify(password_hash, password)
    except (VerifyMismatchError, VerificationError, InvalidHashError):
        return False


def create_access_token(
    subject: UUID,
    expires_delta: timedelta | None = None,
    extra_claims: dict[str, Any] | None = None,
) -> str:
    settings = get_settings()
    expire = datetime.now(timezone.utc) + (
        expires_delta
        if expires_delta is not None
        else timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    payload: dict[str, Any] = {
        "sub": str(subject),
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "type": "access",
    }
    if extra_claims:
        payload.update(extra_claims)
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def decode_access_token(token: str) -> dict[str, Any]:
    settings = get_settings()
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
    except jwt.ExpiredSignatureError as exc:
        raise UnauthorizedError("Access token has expired", code="TOKEN_EXPIRED") from exc
    except jwt.InvalidTokenError as exc:
        raise UnauthorizedError("Invalid access token", code="TOKEN_INVALID") from exc
    if payload.get("type") != "access":
        raise UnauthorizedError("Invalid access token", code="TOKEN_INVALID")
    return payload
