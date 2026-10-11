-- MemoryGuide PostgreSQL schema
-- Keep in sync with backend/alembic/versions/20261011_0001_initial.py

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(32) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(32),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE INDEX ix_users_email ON users (email);
CREATE INDEX ix_users_role ON users (role);

CREATE TABLE patient_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    link_code VARCHAR(16) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_patient_profiles_user_id UNIQUE (user_id),
    CONSTRAINT uq_patient_profiles_link_code UNIQUE (link_code)
);

CREATE INDEX ix_patient_profiles_user_id ON patient_profiles (user_id);
CREATE INDEX ix_patient_profiles_link_code ON patient_profiles (link_code);

CREATE TABLE caregiver_patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caregiver_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    status VARCHAR(32) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_caregiver_patient UNIQUE (caregiver_id, patient_id)
);

CREATE INDEX ix_caregiver_patients_patient_id ON caregiver_patients (patient_id);
CREATE INDEX ix_caregiver_patients_caregiver_status ON caregiver_patients (caregiver_id, status);
CREATE INDEX ix_caregiver_patients_status ON caregiver_patients (status);

CREATE TABLE patient_settings (
    patient_id UUID PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    tracking_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    location_interval_seconds INTEGER NOT NULL DEFAULT 60,
    geofence_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    safe_zone_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    safe_zone_latitude DOUBLE PRECISION,
    safe_zone_longitude DOUBLE PRECISION,
    safe_zone_radius_meters INTEGER,
    help_alert_cooldown_seconds INTEGER NOT NULL DEFAULT 60,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_settings_interval CHECK (
        location_interval_seconds >= 15 AND location_interval_seconds <= 3600
    ),
    CONSTRAINT ck_settings_help_cooldown CHECK (
        help_alert_cooldown_seconds >= 0 AND help_alert_cooldown_seconds <= 3600
    ),
    CONSTRAINT ck_settings_radius CHECK (
        safe_zone_radius_meters IS NULL
        OR (safe_zone_radius_meters >= 50 AND safe_zone_radius_meters <= 10000)
    ),
    CONSTRAINT ck_settings_lat CHECK (
        safe_zone_latitude IS NULL OR (safe_zone_latitude >= -90 AND safe_zone_latitude <= 90)
    ),
    CONSTRAINT ck_settings_lng CHECK (
        safe_zone_longitude IS NULL OR (safe_zone_longitude >= -180 AND safe_zone_longitude <= 180)
    )
);

CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy_meters DOUBLE PRECISION,
    altitude_meters DOUBLE PRECISION,
    speed_mps DOUBLE PRECISION,
    heading_degrees DOUBLE PRECISION,
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_location_lat CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT ck_location_lng CHECK (longitude >= -180 AND longitude <= 180)
);

CREATE INDEX ix_locations_patient_id ON locations (patient_id);
CREATE INDEX ix_locations_recorded_at ON locations (recorded_at);
CREATE INDEX ix_locations_patient_recorded_at ON locations (patient_id, recorded_at);

CREATE TABLE safety_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    created_by_id UUID REFERENCES users (id) ON DELETE SET NULL,
    alert_type VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'open',
    message TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    notification_status VARCHAR(32) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    acknowledged_at TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ
);

CREATE INDEX ix_safety_events_patient_id ON safety_events (patient_id);
CREATE INDEX ix_safety_events_alert_type ON safety_events (alert_type);
CREATE INDEX ix_safety_events_status ON safety_events (status);
CREATE INDEX ix_safety_events_patient_created ON safety_events (patient_id, created_at);
CREATE INDEX ix_safety_events_patient_status ON safety_events (patient_id, status);

CREATE TABLE landmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    name VARCHAR(120) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_landmark_lat CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT ck_landmark_lng CHECK (longitude >= -180 AND longitude <= 180)
);

CREATE INDEX ix_landmarks_patient_id ON landmarks (patient_id);

CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token VARCHAR(512) NOT NULL,
    device_id VARCHAR(128),
    platform VARCHAR(16),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_device_tokens_token UNIQUE (token)
);

CREATE INDEX ix_device_tokens_user_id ON device_tokens (user_id);
CREATE INDEX ix_device_tokens_token ON device_tokens (token);
