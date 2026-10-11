from uuid import UUID

from sqlalchemy.orm import Session

from app.models.patient_settings import PatientSettings


class SettingsRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get(self, patient_id: UUID) -> PatientSettings | None:
        return self.db.get(PatientSettings, patient_id)

    def add(self, settings: PatientSettings) -> PatientSettings:
        self.db.add(settings)
        return settings
