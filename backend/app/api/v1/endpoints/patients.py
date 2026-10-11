from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.user import PatientDetail
from app.services.relationship_service import RelationshipService

router = APIRouter(prefix="/patients", tags=["patients"])


@router.get("/{patient_id}", response_model=SuccessResponse[PatientDetail])
def get_patient(
    patient_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[PatientDetail]:
    data = RelationshipService(db).get_patient(current_user, patient_id)
    return SuccessResponse(data=data, message="Patient retrieved")
