from datetime import datetime
from uuid import UUID

from pydantic import Field, field_serializer

from app.models.caregiver_patient import RelationshipStatus
from app.schemas.common import APIModel
from app.schemas.user import PatientSummary
from app.utils.time import to_iso8601


class LinkPatientRequest(APIModel):
    link_code: str = Field(min_length=6, max_length=16)

    @property
    def normalized_code(self) -> str:
        return self.link_code.strip().upper()


class RelationshipData(APIModel):
    id: UUID
    caregiver_id: UUID
    patient_id: UUID
    status: RelationshipStatus
    created_at: datetime
    patient: PatientSummary

    @field_serializer("created_at")
    def serialize_created_at(self, value: datetime) -> str:
        return to_iso8601(value)
