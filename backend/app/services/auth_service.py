import secrets
from uuid import UUID

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.exceptions import ConflictError, UnauthorizedError
from app.core.security import create_access_token, hash_password, verify_password
from app.models.patient_profile import PatientProfile
from app.models.patient_settings import PatientSettings
from app.models.user import User, UserRole
from app.repositories.user_repository import UserRepository
from app.schemas.auth import LoginRequest, RegisterRequest, TokenData
from app.schemas.user import UserMe


def _unique_link_code(db: Session) -> str:
    repo = UserRepository(db)
    for _ in range(16):
        code = secrets.token_hex(4).upper()
        if repo.get_patient_by_link_code(code) is None:
            return code
    raise RuntimeError("Unable to allocate a unique patient link code")


def to_user_me(user: User) -> UserMe:
    link_code = None
    if user.patient_profile is not None:
        link_code = user.patient_profile.link_code
    return UserMe(
        id=user.id,
        email=user.email,
        role=user.role,
        full_name=user.full_name,
        phone=user.phone,
        is_active=user.is_active,
        created_at=user.created_at,
        link_code=link_code,
    )


class AuthService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.users = UserRepository(db)

    def register(self, payload: RegisterRequest) -> TokenData:
        if self.users.get_by_email(str(payload.email)):
            raise ConflictError("An account with this email already exists", code="DUPLICATE_EMAIL")
        user = User(
            email=str(payload.email).lower(),
            password_hash=hash_password(payload.password),
            role=payload.role,
            full_name=payload.full_name,
            phone=payload.phone,
            is_active=True,
        )
        self.users.add(user)
        self.db.flush()
        if user.role == UserRole.PATIENT:
            user.patient_profile = PatientProfile(user_id=user.id, link_code=_unique_link_code(self.db))
            user.settings = PatientSettings(patient_id=user.id)
        self.db.commit()
        self.db.refresh(user)
        return self._issue_token(user)

    def login(self, payload: LoginRequest) -> TokenData:
        user = self.users.get_by_email(str(payload.email))
        if user is None or not user.is_active or not verify_password(payload.password, user.password_hash):
            raise UnauthorizedError("Invalid email or password", code="AUTHENTICATION_FAILED")
        if user.role == UserRole.PATIENT:
            user = self.users.get_with_profile(user.id) or user
        return self._issue_token(user)

    def get_me(self, user_id: UUID) -> UserMe:
        user = self.users.get_with_profile(user_id)
        if user is None or not user.is_active:
            raise UnauthorizedError("Account is not available")
        return to_user_me(user)

    def _issue_token(self, user: User) -> TokenData:
        settings = get_settings()
        token = create_access_token(user.id)
        return TokenData(
            access_token=token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user=to_user_me(user),
        )
