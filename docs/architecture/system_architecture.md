# MemoryGuide system architecture

MemoryGuide is a caregiver–patient safety system. Two Flutter clients talk to a FastAPI backend. PostgreSQL stores accounts, relationships, settings, location history, alerts, landmarks, and device tokens. Firebase Cloud Messaging is an optional delivery channel for help-request notifications.

```text
patient_app ──┐
              ├── HTTPS / JSON ── FastAPI (/api/v1) ── SQLAlchemy ── PostgreSQL
caregiver_app ┘                         │
                                        └── NotificationService ── FCM (optional)
```

## Backend layers

- **Endpoints** (`app/api`): HTTP, auth dependencies, status codes.
- **Schemas** (`app/schemas`): Pydantic v2 request/response models.
- **Services** (`app/services`): authorization-aware workflows.
- **Repositories** (`app/repositories`): queries and persistence.
- **Models** (`app/models`): SQLAlchemy 2 mappings.
- **Core** (`app/core`): settings, JWT/Argon2, permissions, errors, logging.
- **DB** (`app/db`): engine and sessions (synchronous SQLAlchemy).

Routers are assembled in `app/api/v1/router.py` and mounted from `app/main.py` at `/api/v1`. Health lives at `/health`.

## Authentication

Access tokens are HS256 JWTs. The `sub` claim is the user UUID. Expiration and signature are validated; the user row is then loaded. Inactive users are rejected. Passwords are hashed with Argon2. Login uses a single failure code so callers cannot distinguish unknown emails from bad passwords.

## Authorization

Every patient-scoped operation calls `require_patient_access`. Access is granted only if:

1. the actor is that patient, or
2. the actor is a caregiver with an active relationship, or
3. the actor is an admin created out of band.

Location writes and help-request creation are further restricted to the patient.

## Linking workflow

Patients receive a unique `link_code` at registration. Caregivers cannot attach an arbitrary `patient_id`. They must present the code. This is the consent mechanism.

## Geofencing

On each patient location POST, if a safe zone is enabled and geofence alerts are on, the service computes haversine distance. Crossing out creates `geofence_exit`; returning creates `geofence_enter` and resolves the opposite open alert. Duplicate open alerts of the same type are not created.

## Notifications

`NotificationService` initializes Firebase Admin only when `FIREBASE_CREDENTIALS_FILE` is set and valid. If it is missing, help requests still persist and the API reports `notification.status = skipped`. Delivery is attempted only after commit. Invalid tokens are removed. Notification payloads include `alert_id` and `patient_id` for navigation and omit extra location detail.

## Configuration

Secrets and URLs come from environment variables (`backend/.env.example`). CORS origins are an explicit list. Credentials are never combined with a wildcard origin. Production refuses known insecure `SECRET_KEY` values.

## Tests

Pytest uses an isolated in-memory SQLite database, FastAPI `TestClient`, and a mocked/disabled Firebase gateway. Tests must not use a production `DATABASE_URL`.
