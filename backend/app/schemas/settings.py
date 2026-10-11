from datetime import datetime

from pydantic import Field, field_serializer, model_validator

from app.schemas.common import APIModel
from app.utils.time import to_iso8601


class PatientSettingsData(APIModel):
    tracking_enabled: bool
    location_interval_seconds: int
    geofence_alerts_enabled: bool
    safe_zone_enabled: bool
    safe_zone_latitude: float | None = None
    safe_zone_longitude: float | None = None
    safe_zone_radius_meters: int | None = None
    help_alert_cooldown_seconds: int
    updated_at: datetime

    @field_serializer("updated_at")
    def serialize_updated_at(self, value: datetime) -> str:
        return to_iso8601(value)


class PatientSettingsUpdate(APIModel):
    """Partial update: omitted fields are left unchanged."""

    tracking_enabled: bool | None = None
    location_interval_seconds: int | None = Field(default=None, ge=15, le=3600)
    geofence_alerts_enabled: bool | None = None
    safe_zone_enabled: bool | None = None
    safe_zone_latitude: float | None = Field(default=None, ge=-90, le=90)
    safe_zone_longitude: float | None = Field(default=None, ge=-180, le=180)
    safe_zone_radius_meters: int | None = Field(default=None, ge=50, le=10000)
    help_alert_cooldown_seconds: int | None = Field(default=None, ge=0, le=3600)

    @model_validator(mode="after")
    def validate_safe_zone(self) -> "PatientSettingsUpdate":
        enabling = self.safe_zone_enabled is True
        if enabling:
            if self.safe_zone_latitude is None or self.safe_zone_longitude is None:
                raise ValueError("safe_zone_latitude and safe_zone_longitude are required when enabling the safe zone")
            if self.safe_zone_radius_meters is None:
                raise ValueError("safe_zone_radius_meters is required when enabling the safe zone")
        return self
