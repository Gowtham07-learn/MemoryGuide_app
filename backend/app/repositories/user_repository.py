from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.models.patient_profile import PatientProfile
from app.models.user import User, UserRole


class UserRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, user_id: UUID) -> User | None:
        return self.db.get(User, user_id)

    def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email.lower())
        return self.db.scalar(stmt)

    def get_with_profile(self, user_id: UUID) -> User | None:
        stmt = select(User).options(joinedload(User.patient_profile)).where(User.id == user_id)
        return self.db.scalar(stmt)

    def get_patient_by_link_code(self, link_code: str) -> User | None:
        stmt = (
            select(User)
            .join(PatientProfile, PatientProfile.user_id == User.id)
            .where(
                PatientProfile.link_code == link_code,
                User.role == UserRole.PATIENT,
                User.is_active.is_(True),
            )
        )
        return self.db.scalar(stmt)

    def add(self, user: User) -> User:
        self.db.add(user)
        return user
