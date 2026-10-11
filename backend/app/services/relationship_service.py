from uuid import UUID

from sqlalchemy.orm import Session

from app.core.exceptions import ConflictError, ForbiddenError, NotFoundError
from app.core.permissions import require_patient_access, require_roles
from app.models.caregiver_patient import CaregiverPatient, RelationshipStatus
from app.models.user import User, UserRole
from app.repositories.relationship_repository import RelationshipRepository
from app.repositories.user_repository import UserRepository
from app.schemas.relationship import LinkPatientRequest, RelationshipData
from app.schemas.user import PatientDetail, PatientSummary


class RelationshipService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.users = UserRepository(db)
        self.rels = RelationshipRepository(db)

    def link_patient(self, caregiver: User, payload: LinkPatientRequest) -> RelationshipData:
        require_roles(caregiver, UserRole.CAREGIVER, UserRole.ADMIN)
        code = payload.normalized_code
        patient = self.users.get_patient_by_link_code(code)
        if patient is None:
            raise NotFoundError("Invalid patient link code")
        existing = self.rels.get_pair(caregiver.id, patient.id)
        if existing and existing.status == RelationshipStatus.ACTIVE:
            raise ConflictError("This patient is already linked to your account", code="ALREADY_LINKED")
        if existing:
            existing.status = RelationshipStatus.ACTIVE
            rel = existing
        else:
            rel = CaregiverPatient(
                caregiver_id=caregiver.id,
                patient_id=patient.id,
                status=RelationshipStatus.ACTIVE,
            )
            self.rels.add(rel)
        self.db.commit()
        self.db.refresh(rel)
        return self._to_data(rel, patient)

    def list_patients(self, caregiver: User) -> list[RelationshipData]:
        require_roles(caregiver, UserRole.CAREGIVER, UserRole.ADMIN)
        items = self.rels.list_patients_for_caregiver(caregiver.id)
        return [self._to_data(rel, rel.patient) for rel in items]

    def get_patient(self, actor: User, patient_id: UUID) -> PatientDetail:
        patient = require_patient_access(self.db, actor, patient_id)
        profile = patient.patient_profile
        if profile is None:
            patient = self.users.get_with_profile(patient.id) or patient
            profile = patient.patient_profile
        show_code = actor.id == patient.id or actor.role == UserRole.ADMIN
        return PatientDetail(
            id=patient.id,
            email=patient.email,
            full_name=patient.full_name,
            phone=patient.phone,
            role=patient.role,
            link_code=profile.link_code if profile and show_code else None,
            notes=profile.notes if profile else None,
        )

    def _to_data(self, rel: CaregiverPatient, patient: User) -> RelationshipData:
        return RelationshipData(
            id=rel.id,
            caregiver_id=rel.caregiver_id,
            patient_id=rel.patient_id,
            status=rel.status,
            created_at=rel.created_at,
            patient=PatientSummary(
                id=patient.id,
                email=patient.email,
                full_name=patient.full_name,
                phone=patient.phone,
            ),
        )
