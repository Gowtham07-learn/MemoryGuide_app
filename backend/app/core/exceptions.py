from typing import Any


class AppError(Exception):
    """Application error mapped to a stable API error envelope."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int,
        details: list[Any] | None = None,
    ) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or []


class UnauthorizedError(AppError):
    def __init__(self, message: str = "Authentication required", code: str = "UNAUTHORIZED") -> None:
        super().__init__(code=code, message=message, status_code=401)


class ForbiddenError(AppError):
    def __init__(self, message: str = "You are not allowed to perform this action") -> None:
        super().__init__(code="FORBIDDEN", message=message, status_code=403)


class NotFoundError(AppError):
    def __init__(self, message: str = "Resource not found") -> None:
        super().__init__(code="NOT_FOUND", message=message, status_code=404)


class ConflictError(AppError):
    def __init__(self, message: str, code: str = "CONFLICT") -> None:
        super().__init__(code=code, message=message, status_code=409)


class ValidationAppError(AppError):
    def __init__(self, message: str, details: list[Any] | None = None) -> None:
        super().__init__(
            code="VALIDATION_ERROR",
            message=message,
            status_code=422,
            details=details or [],
        )
