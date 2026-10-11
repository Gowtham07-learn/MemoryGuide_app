from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenData
from app.schemas.common import SuccessResponse
from app.schemas.user import UserMe
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", status_code=status.HTTP_201_CREATED, response_model=SuccessResponse[TokenData])
def register(payload: RegisterRequest, db: Session = Depends(get_db)) -> SuccessResponse[TokenData]:
    data = AuthService(db).register(payload)
    return SuccessResponse(data=data, message="Registration successful")


@router.post("/login", response_model=SuccessResponse[TokenData])
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> SuccessResponse[TokenData]:
    data = AuthService(db).login(payload)
    return SuccessResponse(data=data, message="Login successful")


@router.get("/me", response_model=SuccessResponse[UserMe])
def me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)) -> SuccessResponse[UserMe]:
    data = AuthService(db).get_me(current_user.id)
    return SuccessResponse(data=data, message="Current user retrieved")
