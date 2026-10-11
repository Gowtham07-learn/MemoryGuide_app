from datetime import datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.location import Location


class LocationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def add(self, location: Location) -> Location:
        self.db.add(location)
        return location

    def latest(self, patient_id: UUID) -> Location | None:
        stmt = (
            select(Location)
            .where(Location.patient_id == patient_id)
            .order_by(Location.recorded_at.desc())
            .limit(1)
        )
        return self.db.scalar(stmt)

    def list_for_patient(
        self,
        patient_id: UUID,
        *,
        page: int,
        page_size: int,
        since: datetime | None = None,
        until: datetime | None = None,
    ) -> tuple[list[Location], int]:
        filters = [Location.patient_id == patient_id]
        if since is not None:
            filters.append(Location.recorded_at >= since)
        if until is not None:
            filters.append(Location.recorded_at <= until)
        total = self.db.scalar(select(func.count()).select_from(Location).where(*filters)) or 0
        stmt = (
            select(Location)
            .where(*filters)
            .order_by(Location.recorded_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        return list(self.db.scalars(stmt)), int(total)
