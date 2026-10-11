from __future__ import annotations

import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, CheckConstraint, DateTime, Float, ForeignKey, Integer, Uuid, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.user import User


class PatientSettings(Base):
    __tablename__ = "patient_settings"
    __table_args__ = (
        CheckConstraint(
            "location_interval_seconds >= 15 AND location_interval_seconds <= 3600",
            name="ck_settings_interval",
        ),
        CheckConstraint(
            "help_alert_cooldown_seconds >= 0 AND help_alert_cooldown_seconds <= 3600",
            name="ck_settings_help_cooldown",
        ),
        CheckConstraint(
            "safe_zone_radius_meters IS NULL OR "
            "(safe_zone_radius_meters >= 50 AND safe_zone_radius_meters <= 10000)",
            name="ck_settings_radius",
        ),
        CheckConstraint(
            "safe_zone_latitude IS NULL OR (safe_zone_latitude >= -90 AND safe_zone_latitude <= 90)",
            name="ck_settings_lat",
        ),
        CheckConstraint(
            "safe_zone_longitude IS NULL OR "
            "(safe_zone_longitude >= -180 AND safe_zone_longitude <= 180)",
            name="ck_settings_lng",
        ),
    )

    patient_id: Mapped[uuid.UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    tracking_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    location_interval_seconds: Mapped[int] = mapped_column(Integer, nullable=False, default=60)
    geofence_alerts_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    safe_zone_enabled: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    safe_zone_latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    safe_zone_longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    safe_zone_radius_meters: Mapped[int | None] = mapped_column(Integer, nullable=True)
    help_alert_cooldown_seconds: Mapped[int] = mapped_column(Integer, nullable=False, default=60)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )

    patient: Mapped[User] = relationship(back_populates="settings")
