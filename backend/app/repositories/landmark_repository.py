from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.landmark import Landmark


class LandmarkRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get(self, landmark_id: UUID) -> Landmark | None:
        return self.db.get(Landmark, landmark_id)

    def list_for_patient(self, patient_id: UUID) -> list[Landmark]:
        stmt = (
            select(Landmark)
            .where(Landmark.patient_id == patient_id)
            .order_by(Landmark.created_at.desc())
        )
        return list(self.db.scalars(stmt))

    def add(self, landmark: Landmark) -> Landmark:
        self.db.add(landmark)
        return landmark

    def delete(self, landmark: Landmark) -> None:
        self.db.delete(landmark)
