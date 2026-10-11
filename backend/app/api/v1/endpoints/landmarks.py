from uuid import UUID

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.landmark import LandmarkCreate, LandmarkData, LandmarkUpdate
from app.services.landmark_service import LandmarkService

router = APIRouter(prefix="/patients", tags=["landmarks"])


@router.get("/{patient_id}/landmarks", response_model=SuccessResponse[list[LandmarkData]])
def list_landmarks(
    patient_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[list[LandmarkData]]:
    data = LandmarkService(db).list(current_user, patient_id)
    return SuccessResponse(data=data, message="Landmarks retrieved")


@router.post(
    "/{patient_id}/landmarks",
    status_code=status.HTTP_201_CREATED,
    response_model=SuccessResponse[LandmarkData],
)
def create_landmark(
    patient_id: UUID,
    payload: LandmarkCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[LandmarkData]:
    data = LandmarkService(db).create(current_user, patient_id, payload)
    return SuccessResponse(data=data, message="Landmark created")


@router.put(
    "/{patient_id}/landmarks/{landmark_id}",
    response_model=SuccessResponse[LandmarkData],
)
def update_landmark(
    patient_id: UUID,
    landmark_id: UUID,
    payload: LandmarkUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[LandmarkData]:
    data = LandmarkService(db).update(current_user, patient_id, landmark_id, payload)
    return SuccessResponse(data=data, message="Landmark updated")


@router.delete("/{patient_id}/landmarks/{landmark_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_landmark(
    patient_id: UUID,
    landmark_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Response:
    LandmarkService(db).delete(current_user, patient_id, landmark_id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
