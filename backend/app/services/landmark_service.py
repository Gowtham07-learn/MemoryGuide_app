from uuid import UUID

from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.core.permissions import require_patient_access
from app.models.landmark import Landmark
from app.models.user import User
from app.repositories.landmark_repository import LandmarkRepository
from app.schemas.landmark import LandmarkCreate, LandmarkData, LandmarkUpdate
from app.utils.time import utcnow


class LandmarkService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.landmarks = LandmarkRepository(db)

    def list(self, actor: User, patient_id: UUID) -> list[LandmarkData]:
        require_patient_access(self.db, actor, patient_id)
        return [LandmarkData.model_validate(item) for item in self.landmarks.list_for_patient(patient_id)]

    def create(self, actor: User, patient_id: UUID, payload: LandmarkCreate) -> LandmarkData:
        require_patient_access(self.db, actor, patient_id)
        landmark = Landmark(
            patient_id=patient_id,
            name=payload.name.strip(),
            latitude=payload.latitude,
            longitude=payload.longitude,
            notes=payload.notes,
        )
        self.landmarks.add(landmark)
        self.db.commit()
        self.db.refresh(landmark)
        return LandmarkData.model_validate(landmark)

    def update(
        self, actor: User, patient_id: UUID, landmark_id: UUID, payload: LandmarkUpdate
    ) -> LandmarkData:
        landmark = self._owned(actor, patient_id, landmark_id)
        updates = payload.model_dump(exclude_unset=True)
        if "name" in updates and updates["name"] is not None:
            updates["name"] = updates["name"].strip()
        for key, value in updates.items():
            setattr(landmark, key, value)
        landmark.updated_at = utcnow()
        self.db.commit()
        self.db.refresh(landmark)
        return LandmarkData.model_validate(landmark)

    def delete(self, actor: User, patient_id: UUID, landmark_id: UUID) -> None:
        landmark = self._owned(actor, patient_id, landmark_id)
        self.landmarks.delete(landmark)
        self.db.commit()

    def _owned(self, actor: User, patient_id: UUID, landmark_id: UUID) -> Landmark:
        require_patient_access(self.db, actor, patient_id)
        landmark = self.landmarks.get(landmark_id)
        if landmark is None or landmark.patient_id != patient_id:
            raise NotFoundError("Landmark not found")
        return landmark
