from datetime import datetime
from uuid import UUID

from pydantic import Field, field_serializer

from app.models.device_token import DevicePlatform
from app.schemas.common import APIModel
from app.utils.time import to_iso8601


class DeviceTokenUpsert(APIModel):
    token: str = Field(min_length=8, max_length=512)
    device_id: str | None = Field(default=None, max_length=128)
    platform: DevicePlatform | None = None


class DeviceTokenDelete(APIModel):
    token: str = Field(min_length=8, max_length=512)


class DeviceTokenData(APIModel):
    id: UUID
    device_id: str | None = None
    platform: DevicePlatform | None = None
    updated_at: datetime

    @field_serializer("updated_at")
    def serialize_updated_at(self, value: datetime) -> str:
        return to_iso8601(value)
