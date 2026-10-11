from pydantic import EmailStr, Field, field_validator

from app.models.user import UserRole
from app.schemas.common import APIModel
from app.schemas.user import UserMe


class RegisterRequest(APIModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    full_name: str = Field(min_length=1, max_length=200)
    role: UserRole
    phone: str | None = Field(default=None, max_length=32)

    @field_validator("role")
    @classmethod
    def reject_privileged_roles(cls, value: UserRole) -> UserRole:
        if value == UserRole.ADMIN:
            raise ValueError("Administrative roles cannot be assigned during registration")
        return value

    @field_validator("full_name")
    @classmethod
    def strip_name(cls, value: str) -> str:
        stripped = value.strip()
        if not stripped:
            raise ValueError("full_name cannot be blank")
        return stripped

    @field_validator("password")
    @classmethod
    def password_not_blank(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("password cannot be blank")
        return value


class LoginRequest(APIModel):
    email: EmailStr
    password: str


class TokenData(APIModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user: UserMe
