from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.models.caregiver_patient import CaregiverPatient, RelationshipStatus
from app.models.user import User


class RelationshipRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_pair(self, caregiver_id: UUID, patient_id: UUID) -> CaregiverPatient | None:
        stmt = select(CaregiverPatient).where(
            CaregiverPatient.caregiver_id == caregiver_id,
            CaregiverPatient.patient_id == patient_id,
        )
        return self.db.scalar(stmt)

    def is_active_link(self, caregiver_id: UUID, patient_id: UUID) -> bool:
        rel = self.get_pair(caregiver_id, patient_id)
        return rel is not None and rel.status == RelationshipStatus.ACTIVE

    def list_patients_for_caregiver(self, caregiver_id: UUID) -> list[CaregiverPatient]:
        stmt = (
            select(CaregiverPatient)
            .options(joinedload(CaregiverPatient.patient).joinedload(User.patient_profile))
            .where(
                CaregiverPatient.caregiver_id == caregiver_id,
                CaregiverPatient.status == RelationshipStatus.ACTIVE,
            )
            .order_by(CaregiverPatient.created_at.desc())
        )
        return list(self.db.scalars(stmt).unique())

    def list_active_caregivers(self, patient_id: UUID) -> list[CaregiverPatient]:
        stmt = select(CaregiverPatient).where(
            CaregiverPatient.patient_id == patient_id,
            CaregiverPatient.status == RelationshipStatus.ACTIVE,
        )
        return list(self.db.scalars(stmt))

    def add(self, rel: CaregiverPatient) -> CaregiverPatient:
        self.db.add(rel)
        return rel
