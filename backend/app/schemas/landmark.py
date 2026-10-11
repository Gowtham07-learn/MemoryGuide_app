from datetime import datetime
from uuid import UUID

from pydantic import Field, field_serializer

from app.schemas.common import APIModel
from app.utils.time import to_iso8601


class LandmarkCreate(APIModel):
    name: str = Field(min_length=1, max_length=120)
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    notes: str | None = Field(default=None, max_length=1000)


class LandmarkUpdate(APIModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    notes: str | None = Field(default=None, max_length=1000)


class LandmarkData(APIModel):
    id: UUID
    patient_id: UUID
    name: str
    latitude: float
    longitude: float
    notes: str | None = None
    created_at: datetime
    updated_at: datetime

    @field_serializer("created_at", "updated_at")
    def serialize_dt(self, value: datetime) -> str:
        return to_iso8601(value)
