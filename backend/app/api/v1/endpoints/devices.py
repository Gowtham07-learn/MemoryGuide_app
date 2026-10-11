from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.device import DeviceTokenData, DeviceTokenDelete, DeviceTokenUpsert
from app.services.device_service import DeviceService

router = APIRouter(prefix="/devices", tags=["devices"])


@router.put("/fcm-token", response_model=SuccessResponse[DeviceTokenData])
def upsert_token(
    payload: DeviceTokenUpsert,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SuccessResponse[DeviceTokenData]:
    data = DeviceService(db).upsert(current_user, payload)
    return SuccessResponse(data=data, message="Device token registered")


@router.delete("/fcm-token", status_code=status.HTTP_204_NO_CONTENT)
def delete_token(
    payload: DeviceTokenDelete,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Response:
    DeviceService(db).delete(current_user, payload)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
