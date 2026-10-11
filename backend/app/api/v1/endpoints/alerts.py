from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.safety_event import AlertStatus, AlertType
from app.models.user import User
from app.schemas.alert import AlertData, AlertPatch, HelpRequestCreate, HelpRequestResult
from app.schemas.common import PaginatedData, SuccessResponse
from app.services.alert_service import AlertService

router = APIRouter(tags=["alerts"])


@router.get(
    "/patients/{patient_id}/alerts",
    response_model=SuccessResponse[PaginatedData[AlertData]],
)
def list_alerts(
    patient_id: UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status_filter: AlertStatus | None = Query(default=None, alias="status"),
    alert_type: AlertType | None = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[PaginatedData[AlertData]]:
    data = AlertService(db).list_alerts(
        current_user,
        patient_id,
        page=page,
        page_size=page_size,
        status=status_filter,
        alert_type=alert_type,
    )
    return SuccessResponse(data=data, message="Alerts retrieved")


@router.post(
    "/patients/{patient_id}/help",
    status_code=status.HTTP_201_CREATED,
    response_model=SuccessResponse[HelpRequestResult],
)
def create_help(
    patient_id: UUID,
    payload: HelpRequestCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[HelpRequestResult]:
    data = AlertService(db).create_help(current_user, patient_id, payload)
    return SuccessResponse(data=data, message="Help request created")


@router.patch("/alerts/{alert_id}", response_model=SuccessResponse[AlertData])
def patch_alert(
    alert_id: UUID,
    payload: AlertPatch,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[AlertData]:
    data = AlertService(db).patch(current_user, alert_id, payload)
    return SuccessResponse(data=data, message="Alert updated")
