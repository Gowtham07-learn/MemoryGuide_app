from uuid import UUID

from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError, ValidationAppError
from app.core.permissions import require_patient_access
from app.models.patient_settings import PatientSettings
from app.models.user import User
from app.repositories.settings_repository import SettingsRepository
from app.schemas.settings import PatientSettingsData, PatientSettingsUpdate
from app.utils.time import utcnow


class SettingsService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.settings = SettingsRepository(db)

    def get(self, actor: User, patient_id: UUID) -> PatientSettingsData:
        require_patient_access(self.db, actor, patient_id)
        row = self._get_or_404(patient_id)
        return PatientSettingsData.model_validate(row)

    def update(self, actor: User, patient_id: UUID, payload: PatientSettingsUpdate) -> PatientSettingsData:
        require_patient_access(self.db, actor, patient_id)
        row = self._get_or_404(patient_id)
        updates = payload.model_dump(exclude_unset=True)
        if not updates:
            raise ValidationAppError("No settings fields were provided")
        for key, value in updates.items():
            setattr(row, key, value)
        if row.safe_zone_enabled:
            if row.safe_zone_latitude is None or row.safe_zone_longitude is None or row.safe_zone_radius_meters is None:
                raise ValidationAppError(
                    "Safe zone coordinates and radius must be set before enabling the safe zone"
                )
        row.updated_at = utcnow()
        self.db.commit()
        self.db.refresh(row)
        return PatientSettingsData.model_validate(row)

    def _get_or_404(self, patient_id: UUID) -> PatientSettings:
        row = self.settings.get(patient_id)
        if row is None:
            raise NotFoundError("Patient settings not found")
        return row
