"""Insert development-only sample users. Never run against production."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.config import get_settings
from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models.caregiver_patient import CaregiverPatient, RelationshipStatus
from app.models.patient_profile import PatientProfile
from app.models.patient_settings import PatientSettings
from app.models.user import User, UserRole

DEV_PASSWORD = "DevPass123!"


def main() -> None:
    settings = get_settings()
    if settings.is_production:
        raise SystemExit("Refusing to seed a production environment")

    db = SessionLocal()
    try:
        if db.query(User).filter(User.email == "patient.dev@example.com").first():
            print("Development users already exist")
            return
        password_hash = hash_password(DEV_PASSWORD)
        patient = User(
            email="patient.dev@example.com",
            password_hash=password_hash,
            role=UserRole.PATIENT,
            full_name="Dev Patient",
            is_active=True,
        )
        caregiver = User(
            email="caregiver.dev@example.com",
            password_hash=password_hash,
            role=UserRole.CAREGIVER,
            full_name="Dev Caregiver",
            is_active=True,
        )
        db.add_all([patient, caregiver])
        db.flush()
        db.add(PatientProfile(user_id=patient.id, link_code="DEVLINK1"))
        db.add(PatientSettings(patient_id=patient.id))
        db.add(
            CaregiverPatient(
                caregiver_id=caregiver.id,
                patient_id=patient.id,
                status=RelationshipStatus.ACTIVE,
            )
        )
        db.commit()
        print("Seeded patient.dev@example.com and caregiver.dev@example.com")
        print(f"Password: {DEV_PASSWORD}")
        print("Patient link code: DEVLINK1")
    finally:
        db.close()


if __name__ == "__main__":
    main()
