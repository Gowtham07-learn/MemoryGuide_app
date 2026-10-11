from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.common import PaginatedData, SuccessResponse
from app.schemas.location import LocationCreate, LocationData, PatientStatusData
from app.services.location_service import LocationService

router = APIRouter(prefix="/patients", tags=["locations"])


@router.post(
    "/{patient_id}/locations",
    status_code=status.HTTP_201_CREATED,
    response_model=SuccessResponse[LocationData],
)
def create_location(
    patient_id: UUID,
    payload: LocationCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[LocationData]:
    data = LocationService(db).record(current_user, patient_id, payload)
    return SuccessResponse(data=data, message="Location recorded")


@router.get("/{patient_id}/status", response_model=SuccessResponse[PatientStatusData])
def get_status(
    patient_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[PatientStatusData]:
    data = LocationService(db).status(current_user, patient_id)
    return SuccessResponse(data=data, message="Patient status retrieved")


@router.get("/{patient_id}/locations", response_model=SuccessResponse[PaginatedData[LocationData]])
def list_locations(
    patient_id: UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    since: datetime | None = None,
    until: datetime | None = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[PaginatedData[LocationData]]:
    data = LocationService(db).history(
        current_user,
        patient_id,
        page=page,
        page_size=page_size,
        since=since,
        until=until,
    )
    return SuccessResponse(data=data, message="Location history retrieved")
