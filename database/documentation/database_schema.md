# MemoryGuide database schema

PostgreSQL is the supported production database. Alembic migrations are the source of truth for applying schema changes. The SQL snapshot in `database/schema/memoryguide_schema.sql` matches the initial migration `backend/alembic/versions/20261011_0001_initial.py`.

All timestamps are stored in UTC (`TIMESTAMPTZ`).

## Identity vs patient profile

- `users` stores account identity: email, password hash, role, name, phone, and active flag.
- `patient_profiles` stores patient-only data, including the consent `link_code` used to authorize caregiver linking.
- `patient_id` in all feature tables is the patient's `users.id`.

## Tables

### users

| Column | Type | Notes |
| --- | --- | --- |
| id | UUID PK | |
| email | VARCHAR(255) unique | Stored lowercase |
| password_hash | VARCHAR(255) | Argon2, never returned by the API |
| role | VARCHAR(32) | `patient`, `caregiver`, `admin` |
| full_name | VARCHAR(200) | |
| phone | VARCHAR(32) nullable | |
| is_active | BOOLEAN | Soft disable |
| created_at / updated_at | TIMESTAMPTZ | |

Public registration may only create `patient` or `caregiver`. `admin` is created by `backend/scripts/create_admin.py`.

### patient_profiles

One row per patient user. `link_code` is unique and is shown only to the patient (and admins). Caregivers submit this code to create a relationship; knowing a patient UUID is not enough.

### caregiver_patients

Explicit many-to-many authorization. Unique `(caregiver_id, patient_id)`. `status` is `active` or `revoked`. Relinking a revoked pair reactivates the same row.

### patient_settings

Primary key is `patient_id`. Defaults: tracking on, 60s interval, geofence alerts on, safe zone off, 60s help cooldown. PUT updates only provided fields.

### locations

Append-only history. Indexed on `(patient_id, recorded_at)`. Coordinate check constraints apply.

### safety_events

Alert types: `help_request`, `geofence_exit`, `geofence_enter`. Statuses: `open`, `acknowledged`, `resolved`. Help requests are this table with `alert_type = help_request`. `notification_status` records delivery outcome after the row is committed.

### landmarks

Named coordinates belonging to a patient. Hard-deleted.

### device_tokens

One unique FCM token string globally. Re-registering the same token assigns it to the current user (device rotation / account switch). Tokens are never returned in API responses.

## Deletion

User deletion cascades to profiles, settings, locations, alerts, landmarks, device tokens, and relationships. Alert `created_by_id` is set null if that user is deleted.

## Indexes

Frequent lookups are indexed: user email/role, link code, relationship pair and status, location patient+time, alert patient+status/time, landmark patient, device token.

## Initialization

```bash
cd backend
alembic upgrade head
python scripts/seed_dev.py   # development only
```
