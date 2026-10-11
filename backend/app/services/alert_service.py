from datetime import timedelta
from math import ceil
from uuid import UUID

from sqlalchemy.orm import Session

from app.core.exceptions import ConflictError, ForbiddenError, NotFoundError, ValidationAppError
from app.core.permissions import require_patient_access
from app.models.safety_event import AlertStatus, AlertType, SafetyEvent
from app.models.user import User, UserRole
from app.repositories.alert_repository import AlertRepository
from app.repositories.settings_repository import SettingsRepository
from app.repositories.user_repository import UserRepository
from app.schemas.alert import (
    AlertData,
    AlertPatch,
    HelpRequestCreate,
    HelpRequestResult,
    NotificationResultData,
)
from app.schemas.common import PaginatedData, PaginationMeta
from app.services.notification_service import NotificationService
from app.utils.time import utcnow

ALLOWED_TRANSITIONS = {
    AlertStatus.OPEN: {AlertStatus.ACKNOWLEDGED, AlertStatus.RESOLVED},
    AlertStatus.ACKNOWLEDGED: {AlertStatus.RESOLVED},
    AlertStatus.RESOLVED: set(),
}


class AlertService:
    def __init__(self, db: Session, notifications: NotificationService | None = None) -> None:
        self.db = db
        self.alerts = AlertRepository(db)
        self.settings = SettingsRepository(db)
        self.users = UserRepository(db)
        self.notifications = notifications or NotificationService(db)

    def list_alerts(
        self,
        actor: User,
        patient_id: UUID,
        *,
        page: int,
        page_size: int,
        status: AlertStatus | None = None,
        alert_type: AlertType | None = None,
    ) -> PaginatedData[AlertData]:
        require_patient_access(self.db, actor, patient_id)
        items, total = self.alerts.list_for_patient(
            patient_id,
            page=page,
            page_size=page_size,
            status=status,
            alert_type=alert_type,
        )
        return PaginatedData(
            items=[AlertData.model_validate(item) for item in items],
            pagination=PaginationMeta(
                page=page,
                page_size=page_size,
                total=total,
                total_pages=ceil(total / page_size) if page_size else 0,
            ),
        )

    def create_help(self, actor: User, patient_id: UUID, payload: HelpRequestCreate) -> HelpRequestResult:
        require_patient_access(self.db, actor, patient_id)
        if actor.id != patient_id or actor.role != UserRole.PATIENT:
            raise ForbiddenError("Only the patient can create a help request")
        settings = self.settings.get(patient_id)
        cooldown = settings.help_alert_cooldown_seconds if settings else 60
        if cooldown > 0:
            recent = self.alerts.recent_help_request(patient_id, utcnow() - timedelta(seconds=cooldown))
            if recent is not None and recent.status != AlertStatus.RESOLVED:
                raise ConflictError(
                    "A help request was already created recently",
                    code="DUPLICATE_HELP_REQUEST",
                )
        event = SafetyEvent(
            patient_id=patient_id,
            created_by_id=actor.id,
            alert_type=AlertType.HELP_REQUEST,
            status=AlertStatus.OPEN,
            message=payload.message,
            latitude=payload.latitude,
            longitude=payload.longitude,
            notification_status="pending",
        )
        self.alerts.add(event)
        self.db.commit()
        self.db.refresh(event)

        notify = self.notifications.notify_help_request(event, actor.full_name)
        event.notification_status = notify.status
        self.db.commit()
        self.db.refresh(event)
        return HelpRequestResult(
            alert=AlertData.model_validate(event),
            notification=NotificationResultData(
                attempted=notify.attempted,
                delivered_count=notify.delivered_count,
                status=notify.status,
                firebase_configured=notify.firebase_configured,
            ),
        )

    def patch(self, actor: User, alert_id: UUID, payload: AlertPatch) -> AlertData:
        event = self.alerts.get(alert_id)
        if event is None:
            raise NotFoundError("Alert not found")
        require_patient_access(self.db, actor, event.patient_id)
        if actor.role == UserRole.PATIENT:
            if actor.id != event.patient_id or payload.status != AlertStatus.RESOLVED:
                raise ForbiddenError("Patients may only resolve their own alerts")
        elif actor.role not in {UserRole.CAREGIVER, UserRole.ADMIN}:
            raise ForbiddenError("You cannot update this alert")
        allowed = ALLOWED_TRANSITIONS.get(event.status, set())
        if payload.status not in allowed:
            raise ValidationAppError(
                f"Cannot transition alert from {event.status.value} to {payload.status.value}"
            )
        now = utcnow()
        event.status = payload.status
        if payload.status == AlertStatus.ACKNOWLEDGED:
            event.acknowledged_at = now
        if payload.status == AlertStatus.RESOLVED:
            event.resolved_at = now
        self.db.commit()
        self.db.refresh(event)
        return AlertData.model_validate(event)
