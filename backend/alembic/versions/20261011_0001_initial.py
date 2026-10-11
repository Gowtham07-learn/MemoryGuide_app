"""initial memoryguide schema

Revision ID: 20261011_0001
Revises:
Create Date: 2026-10-11
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "20261011_0001"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("role", sa.String(32), nullable=False),
        sa.Column("full_name", sa.String(200), nullable=False),
        sa.Column("phone", sa.String(32), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("email", name="uq_users_email"),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)
    op.create_index("ix_users_role", "users", ["role"])

    op.create_table(
        "patient_profiles",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("link_code", sa.String(16), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("user_id", name="uq_patient_profiles_user_id"),
        sa.UniqueConstraint("link_code", name="uq_patient_profiles_link_code"),
    )
    op.create_index("ix_patient_profiles_user_id", "patient_profiles", ["user_id"], unique=True)
    op.create_index("ix_patient_profiles_link_code", "patient_profiles", ["link_code"], unique=True)

    op.create_table(
        "caregiver_patients",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("caregiver_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("patient_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("status", sa.String(32), nullable=False, server_default="active"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("caregiver_id", "patient_id", name="uq_caregiver_patient"),
    )
    op.create_index("ix_caregiver_patients_patient_id", "caregiver_patients", ["patient_id"])
    op.create_index("ix_caregiver_patients_caregiver_status", "caregiver_patients", ["caregiver_id", "status"])
    op.create_index("ix_caregiver_patients_status", "caregiver_patients", ["status"])

    op.create_table(
        "patient_settings",
        sa.Column("patient_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("tracking_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("location_interval_seconds", sa.Integer(), nullable=False, server_default="60"),
        sa.Column("geofence_alerts_enabled", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("safe_zone_enabled", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("safe_zone_latitude", sa.Float(), nullable=True),
        sa.Column("safe_zone_longitude", sa.Float(), nullable=True),
        sa.Column("safe_zone_radius_meters", sa.Integer(), nullable=True),
        sa.Column("help_alert_cooldown_seconds", sa.Integer(), nullable=False, server_default="60"),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint(
            "location_interval_seconds >= 15 AND location_interval_seconds <= 3600",
            name="ck_settings_interval",
        ),
        sa.CheckConstraint(
            "help_alert_cooldown_seconds >= 0 AND help_alert_cooldown_seconds <= 3600",
            name="ck_settings_help_cooldown",
        ),
        sa.CheckConstraint(
            "safe_zone_radius_meters IS NULL OR (safe_zone_radius_meters >= 50 AND safe_zone_radius_meters <= 10000)",
            name="ck_settings_radius",
        ),
        sa.CheckConstraint(
            "safe_zone_latitude IS NULL OR (safe_zone_latitude >= -90 AND safe_zone_latitude <= 90)",
            name="ck_settings_lat",
        ),
        sa.CheckConstraint(
            "safe_zone_longitude IS NULL OR (safe_zone_longitude >= -180 AND safe_zone_longitude <= 180)",
            name="ck_settings_lng",
        ),
    )

    op.create_table(
        "locations",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("patient_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("accuracy_meters", sa.Float(), nullable=True),
        sa.Column("altitude_meters", sa.Float(), nullable=True),
        sa.Column("speed_mps", sa.Float(), nullable=True),
        sa.Column("heading_degrees", sa.Float(), nullable=True),
        sa.Column("recorded_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("latitude >= -90 AND latitude <= 90", name="ck_location_lat"),
        sa.CheckConstraint("longitude >= -180 AND longitude <= 180", name="ck_location_lng"),
    )
    op.create_index("ix_locations_patient_id", "locations", ["patient_id"])
    op.create_index("ix_locations_recorded_at", "locations", ["recorded_at"])
    op.create_index("ix_locations_patient_recorded_at", "locations", ["patient_id", "recorded_at"])

    op.create_table(
        "safety_events",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("patient_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("created_by_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("alert_type", sa.String(32), nullable=False),
        sa.Column("status", sa.String(32), nullable=False, server_default="open"),
        sa.Column("message", sa.Text(), nullable=True),
        sa.Column("latitude", sa.Float(), nullable=True),
        sa.Column("longitude", sa.Float(), nullable=True),
        sa.Column("notification_status", sa.String(32), nullable=False, server_default="pending"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("acknowledged_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.create_index("ix_safety_events_patient_id", "safety_events", ["patient_id"])
    op.create_index("ix_safety_events_alert_type", "safety_events", ["alert_type"])
    op.create_index("ix_safety_events_status", "safety_events", ["status"])
    op.create_index("ix_safety_events_patient_created", "safety_events", ["patient_id", "created_at"])
    op.create_index("ix_safety_events_patient_status", "safety_events", ["patient_id", "status"])

    op.create_table(
        "landmarks",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("patient_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("latitude", sa.Float(), nullable=False),
        sa.Column("longitude", sa.Float(), nullable=False),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("latitude >= -90 AND latitude <= 90", name="ck_landmark_lat"),
        sa.CheckConstraint("longitude >= -180 AND longitude <= 180", name="ck_landmark_lng"),
    )
    op.create_index("ix_landmarks_patient_id", "landmarks", ["patient_id"])

    op.create_table(
        "device_tokens",
        sa.Column("id", sa.Uuid(as_uuid=True), primary_key=True, nullable=False),
        sa.Column("user_id", sa.Uuid(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("token", sa.String(512), nullable=False),
        sa.Column("device_id", sa.String(128), nullable=True),
        sa.Column("platform", sa.String(16), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("token", name="uq_device_tokens_token"),
    )
    op.create_index("ix_device_tokens_user_id", "device_tokens", ["user_id"])
    op.create_index("ix_device_tokens_token", "device_tokens", ["token"])


def downgrade() -> None:
    op.drop_table("device_tokens")
    op.drop_table("landmarks")
    op.drop_table("safety_events")
    op.drop_table("locations")
    op.drop_table("patient_settings")
    op.drop_table("caregiver_patients")
    op.drop_table("patient_profiles")
    op.drop_table("users")
