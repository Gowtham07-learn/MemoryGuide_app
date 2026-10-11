from __future__ import annotations

import enum
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Index, UniqueConstraint, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.models.user import User


class RelationshipStatus(str, enum.Enum):
    ACTIVE = "active"
    REVOKED = "revoked"


class CaregiverPatient(Base):
    __tablename__ = "caregiver_patients"
    __table_args__ = (
        UniqueConstraint("caregiver_id", "patient_id", name="uq_caregiver_patient"),
        Index("ix_caregiver_patients_patient_id", "patient_id"),
        Index("ix_caregiver_patients_caregiver_status", "caregiver_id", "status"),
    )

    id: Mapped[uuid.UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    caregiver_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    patient_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    status: Mapped[RelationshipStatus] = mapped_column(
        Enum(
            RelationshipStatus,
            native_enum=False,
            length=32,
            values_callable=lambda items: [item.value for item in items],
        ),
        nullable=False,
        default=RelationshipStatus.ACTIVE,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )

    caregiver: Mapped[User] = relationship(foreign_keys=[caregiver_id])
    patient: Mapped[User] = relationship(foreign_keys=[patient_id])
