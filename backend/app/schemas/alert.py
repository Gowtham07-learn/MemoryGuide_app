from datetime import datetime
from uuid import UUID

from pydantic import Field, field_serializer

from app.models.safety_event import AlertStatus, AlertType
from app.schemas.common import APIModel
from app.utils.time import to_iso8601


class HelpRequestCreate(APIModel):
    message: str | None = Field(default=None, max_length=1000)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)


class AlertData(APIModel):
    id: UUID
    patient_id: UUID
    alert_type: AlertType
    status: AlertStatus
    message: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    notification_status: str
    created_at: datetime
    updated_at: datetime
    acknowledged_at: datetime | None = None
    resolved_at: datetime | None = None

    @field_serializer("created_at", "updated_at", "acknowledged_at", "resolved_at")
    def serialize_dt(self, value: datetime | None) -> str | None:
        if value is None:
            return None
        return to_iso8601(value)


class AlertPatch(APIModel):
    status: AlertStatus


class NotificationResultData(APIModel):
    attempted: bool
    delivered_count: int = 0
    status: str
    firebase_configured: bool = False


class HelpRequestResult(APIModel):
    alert: AlertData
    notification: NotificationResultData
