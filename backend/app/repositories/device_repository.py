from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.device_token import DeviceToken


class DeviceRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_token(self, token: str) -> DeviceToken | None:
        return self.db.scalar(select(DeviceToken).where(DeviceToken.token == token))

    def list_for_user(self, user_id: UUID) -> list[DeviceToken]:
        return list(self.db.scalars(select(DeviceToken).where(DeviceToken.user_id == user_id)))

    def list_for_users(self, user_ids: list[UUID]) -> list[DeviceToken]:
        if not user_ids:
            return []
        stmt = select(DeviceToken).where(DeviceToken.user_id.in_(user_ids))
        return list(self.db.scalars(stmt))

    def add(self, device: DeviceToken) -> DeviceToken:
        self.db.add(device)
        return device

    def delete(self, device: DeviceToken) -> None:
        self.db.delete(device)
