from sqlalchemy.orm import Session

from app.core.exceptions import ForbiddenError, NotFoundError
from app.models.device_token import DeviceToken
from app.models.user import User
from app.repositories.device_repository import DeviceRepository
from app.schemas.device import DeviceTokenData, DeviceTokenDelete, DeviceTokenUpsert
from app.utils.time import utcnow


class DeviceService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.devices = DeviceRepository(db)

    def upsert(self, actor: User, payload: DeviceTokenUpsert) -> DeviceTokenData:
        existing = self.devices.get_by_token(payload.token)
        if existing is None:
            device = DeviceToken(
                user_id=actor.id,
                token=payload.token,
                device_id=payload.device_id,
                platform=payload.platform,
            )
            self.devices.add(device)
        else:
            device = existing
            device.user_id = actor.id
            device.device_id = payload.device_id or device.device_id
            device.platform = payload.platform or device.platform
            device.updated_at = utcnow()
        self.db.commit()
        self.db.refresh(device)
        return DeviceTokenData.model_validate(device)

    def delete(self, actor: User, payload: DeviceTokenDelete) -> None:
        device = self.devices.get_by_token(payload.token)
        if device is None:
            raise NotFoundError("Device token not found")
        if device.user_id != actor.id:
            raise ForbiddenError("You cannot remove another user's device token")
        self.devices.delete(device)
        self.db.commit()
