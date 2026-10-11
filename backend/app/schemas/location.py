from datetime import datetime, timedelta, timezone
from uuid import UUID

from pydantic import Field, field_serializer, field_validator, model_validator

from app.schemas.common import APIModel
from app.utils.time import ensure_utc, to_iso8601, utcnow


class LocationCreate(APIModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    accuracy_meters: float | None = Field(default=None, ge=0)
    altitude_meters: float | None = None
    speed_mps: float | None = Field(default=None, ge=0)
    heading_degrees: float | None = Field(default=None, ge=0, le=360)
    recorded_at: datetime | None = None

    @field_validator("recorded_at")
    @classmethod
    def not_too_far_future(cls, value: datetime | None) -> datetime | None:
        if value is None:
            return value
        value = ensure_utc(value)
        if value > utcnow() + timedelta(minutes=5):
            raise ValueError("recorded_at cannot be more than 5 minutes in the future")
        return value


class LocationData(APIModel):
    id: UUID
    patient_id: UUID
    latitude: float
    longitude: float
    accuracy_meters: float | None = None
    altitude_meters: float | None = None
    speed_mps: float | None = None
    heading_degrees: float | None = None
    recorded_at: datetime
    created_at: datetime

    @field_serializer("recorded_at", "created_at")
    def serialize_dt(self, value: datetime) -> str:
        return to_iso8601(value)


class LatestLocationData(APIModel):
    latitude: float
    longitude: float
    accuracy_meters: float | None = None
    recorded_at: datetime
    age_seconds: int | None = None

    @field_serializer("recorded_at")
    def serialize_recorded_at(self, value: datetime) -> str:
        return to_iso8601(value)

    @model_validator(mode="after")
    def compute_age(self) -> "LatestLocationData":
        if self.age_seconds is None:
            delta = utcnow() - ensure_utc(self.recorded_at)
            object.__setattr__(self, "age_seconds", max(0, int(delta.total_seconds())))
        return self


class PatientStatusData(APIModel):
    patient_id: UUID
    tracking_enabled: bool
    latest_location: LatestLocationData | None = None
    inside_safe_zone: bool | None = None
    open_alert_count: int = 0
    location_available: bool = False
