from datetime import datetime
from uuid import UUID

from pydantic import EmailStr, Field, field_serializer

from app.models.user import UserRole
from app.schemas.common import APIModel
from app.utils.time import to_iso8601


class UserPublic(APIModel):
    id: UUID
    email: EmailStr
    role: UserRole
    full_name: str
    phone: str | None = None
    is_active: bool
    created_at: datetime

    @field_serializer("created_at")
    def serialize_created_at(self, value: datetime) -> str:
        return to_iso8601(value)


class PatientSummary(APIModel):
    id: UUID
    email: EmailStr
    full_name: str
    phone: str | None = None
    role: UserRole = UserRole.PATIENT


class PatientDetail(PatientSummary):
    link_code: str | None = None
    notes: str | None = None


class UserMe(UserPublic):
    link_code: str | None = None
