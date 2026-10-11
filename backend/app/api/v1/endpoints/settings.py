from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.settings import PatientSettingsData, PatientSettingsUpdate
from app.services.settings_service import SettingsService

router = APIRouter(prefix="/patients", tags=["settings"])


@router.get("/{patient_id}/settings", response_model=SuccessResponse[PatientSettingsData])
def get_settings(
    patient_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[PatientSettingsData]:
    data = SettingsService(db).get(current_user, patient_id)
    return SuccessResponse(data=data, message="Settings retrieved")


@router.put("/{patient_id}/settings", response_model=SuccessResponse[PatientSettingsData])
def update_settings(
    patient_id: UUID,
    payload: PatientSettingsUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[PatientSettingsData]:
    data = SettingsService(db).update(current_user, patient_id, payload)
    return SuccessResponse(data=data, message="Settings updated")
