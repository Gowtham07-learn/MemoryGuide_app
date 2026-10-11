from uuid import UUID

from sqlalchemy.orm import Session

from app.core.exceptions import ForbiddenError, NotFoundError
from app.models.user import User, UserRole
from app.repositories.user_repository import UserRepository


def require_roles(user: User, *roles: UserRole) -> None:
    if user.role not in roles:
        raise ForbiddenError("This action is not permitted for your role")


def get_patient_user(db: Session, patient_id: UUID) -> User:
    patient = UserRepository(db).get_by_id(patient_id)
    if patient is None or patient.role != UserRole.PATIENT or not patient.is_active:
        raise NotFoundError("Patient not found")
    return patient


def can_access_patient(db: Session, actor: User, patient_id: UUID) -> bool:
    if actor.role == UserRole.ADMIN:
        return True
    if actor.id == patient_id and actor.role == UserRole.PATIENT:
        return True
    if actor.role == UserRole.CAREGIVER:
        from app.repositories.relationship_repository import RelationshipRepository

        return RelationshipRepository(db).is_active_link(actor.id, patient_id)
    return False


def require_patient_access(db: Session, actor: User, patient_id: UUID) -> User:
    """Return the patient user if the actor is authorized; otherwise 403/404."""
    patient = get_patient_user(db, patient_id)
    if can_access_patient(db, actor, patient.id):
        return patient
    raise ForbiddenError("You do not have access to this patient")
