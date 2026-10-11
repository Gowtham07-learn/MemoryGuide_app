from __future__ import annotations

import enum
import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, DateTime, Enum, String, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.device_token import DeviceToken
    from app.models.patient_profile import PatientProfile
    from app.models.patient_settings import PatientSettings


class UserRole(str, enum.Enum):
    PATIENT = "patient"
    CAREGIVER = "caregiver"
    ADMIN = "admin"


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole, native_enum=False, length=32, values_callable=lambda items: [item.value for item in items]),
        nullable=False,
        index=True,
    )
    full_name: Mapped[str] = mapped_column(String(200), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(32), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )

    patient_profile: Mapped[PatientProfile | None] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan"
    )
    settings: Mapped[PatientSettings | None] = relationship(
        back_populates="patient", uselist=False, cascade="all, delete-orphan"
    )
    device_tokens: Mapped[list[DeviceToken]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
