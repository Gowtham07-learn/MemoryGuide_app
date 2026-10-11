from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.relationship import LinkPatientRequest, RelationshipData
from app.services.relationship_service import RelationshipService

router = APIRouter(prefix="/caregivers", tags=["caregivers"])


@router.post(
    "/patients",
    status_code=status.HTTP_201_CREATED,
    response_model=SuccessResponse[RelationshipData],
)
def link_patient(
    payload: LinkPatientRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[RelationshipData]:
    data = RelationshipService(db).link_patient(current_user, payload)
    return SuccessResponse(data=data, message="Patient linked successfully")


@router.get("/patients", response_model=SuccessResponse[list[RelationshipData]])
def list_patients(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[list[RelationshipData]]:
    data = RelationshipService(db).list_patients(current_user)
    return SuccessResponse(data=data, message="Linked patients retrieved")
