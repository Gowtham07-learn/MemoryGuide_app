# MemoryGuide API contract

Base URL examples:

- Local machine: `http://127.0.0.1:8000`
- Android emulator to host machine: `http://10.0.2.2:8000`
- iOS simulator: `http://127.0.0.1:8000`
- Physical device: `http://<LAN-IP>:8000` — `localhost` on a phone is the phone itself

Versioned API prefix: `/api/v1`  
Interactive docs: `/docs`  
OpenAPI JSON: `/openapi.json`

JSON field names are `snake_case`. Timestamps are UTC ISO-8601 with a `Z` suffix.

Protected endpoints require `Authorization: Bearer <access_token>`.

## Envelope

Success:

```json
{
  "success": true,
  "data": {},
  "message": "Operation completed"
}
```

Error:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": []
  }
}
```

`DELETE` landmark and FCM token endpoints return `204 No Content` with an empty body.

## Pagination

List endpoints that can grow (`GET .../locations`, `GET .../alerts`) accept:

- `page` (default 1, min 1)
- `page_size` (default 20, max 100)

`data` contains `items` and `pagination: {page, page_size, total, total_pages}`.

## Error codes

| HTTP | code | Meaning |
| --- | --- | --- |
| 401 | UNAUTHORIZED | Missing bearer token |
| 401 | TOKEN_INVALID | Malformed or forged JWT |
| 401 | TOKEN_EXPIRED | JWT expired |
| 401 | AUTHENTICATION_FAILED | Login failed (same message whether email exists or not) |
| 403 | FORBIDDEN | Authenticated but not allowed |
| 404 | NOT_FOUND | Unknown or unauthorized-as-missing resource |
| 409 | DUPLICATE_EMAIL | Registration email taken |
| 409 | ALREADY_LINKED | Caregiver already linked to that patient |
| 409 | DUPLICATE_HELP_REQUEST | Open/recent help request still in cooldown |
| 422 | VALIDATION_ERROR | Request schema or transition invalid |
| 500 | DATABASE_ERROR | Persistence failure (no stack traces) |
| 503 | DATABASE_UNAVAILABLE | `/ready` cannot reach the database |

## Authorization

- Patients access only their own `patient_id`.
- Caregivers access only patients linked through an **active** `caregiver_patients` row.
- Knowing a UUID is not authorization.
- Roles in JWTs are informational; authorization always loads the user from the database.
- Registration cannot create `admin`.

### Caregiver linking (consent)

`POST /api/v1/caregivers/patients` does **not** accept a patient id. The patient shares `link_code` from `GET /api/v1/auth/me`. The caregiver submits `{ "link_code": "ABCD1234" }`. Invalid codes return 404.

## Roles and operations

| Action | Patient (self) | Linked caregiver |
| --- | --- | --- |
| Read profile/settings/status/locations/alerts/landmarks | yes | yes |
| Update settings / landmarks | yes | yes |
| Submit location | yes | no |
| Create help request | yes | no |
| Acknowledge alert | no | yes |
| Resolve alert | yes | yes |
| Register FCM token | own user | own user |

## Health

### `GET /health`

Liveness. Does not require the database.

### `GET /ready`

Readiness including a `SELECT 1` against the database. Returns 503 if unreachable. Does not expose connection details.

## Authentication

### `POST /api/v1/auth/register` → 201

```json
{
  "email": "user@example.com",
  "password": "at-least-8-chars",
  "full_name": "Name",
  "role": "patient",
  "phone": null
}
```

`role` must be `patient` or `caregiver`. Patient registration also creates profile, default settings, and `link_code`.

Response `data`: `{access_token, token_type, expires_in, user}`.

### `POST /api/v1/auth/login` → 200

```json
{ "email": "user@example.com", "password": "..." }
```

### `GET /api/v1/auth/me` → 200

Returns the current user. Patients include `link_code`. Password hashes are never returned.

## Caregivers and patients

### `POST /api/v1/caregivers/patients` → 201

Body: `{ "link_code": "DEVLINK1" }`

### `GET /api/v1/caregivers/patients` → 200

List of active relationships for the authenticated caregiver only.

### `GET /api/v1/patients/{patient_id}` → 200

Caregivers do not receive `link_code`.

## Settings

### `GET /api/v1/patients/{patient_id}/settings` → 200

### `PUT /api/v1/patients/{patient_id}/settings` → 200

**Partial merge:** only submitted fields change. Omitted fields keep their current values.

Defaults: `tracking_enabled=true`, `location_interval_seconds=60` (15–3600), `geofence_alerts_enabled=true`, `safe_zone_enabled=false`, `help_alert_cooldown_seconds=60`. Enabling the safe zone requires latitude, longitude, and `safe_zone_radius_meters` (50–10000).

## Locations

### `POST /api/v1/patients/{patient_id}/locations` → 201

```json
{
  "latitude": 12.97,
  "longitude": 77.59,
  "accuracy_meters": 8,
  "altitude_meters": null,
  "speed_mps": null,
  "heading_degrees": null,
  "recorded_at": "2026-10-11T16:00:00Z"
}
```

`recorded_at` defaults to server UTC. Values more than five minutes in the future are rejected. If a safe zone is enabled, a geofence alert may be created.

### `GET /api/v1/patients/{patient_id}/status` → 200

```json
{
  "patient_id": "...",
  "tracking_enabled": true,
  "latest_location": null,
  "inside_safe_zone": null,
  "open_alert_count": 0,
  "location_available": false
}
```

Missing location is `latest_location: null` and `location_available: false`. The API does not invent an online/offline device state.

### `GET /api/v1/patients/{patient_id}/locations` → 200

Newest first. Optional `since` and `until` query parameters.

## Alerts

### `GET /api/v1/patients/{patient_id}/alerts` → 200

Optional filters: `status`, `alert_type`.

### `POST /api/v1/patients/{patient_id}/help` → 201

Patient only. The alert is committed first. Notifications are attempted afterward. Firebase failures do not delete the alert.

`data.notification.status`: `skipped` | `no_devices` | `sent` | `partial` | `failed`.  
`skipped` means Firebase is not configured (local/dev default). This is not reported as delivered.

### `PATCH /api/v1/alerts/{alert_id}` → 200

```json
{ "status": "acknowledged" }
```

Transitions: `open → acknowledged|resolved`, `acknowledged → resolved`. No reverse transitions.

## Landmarks

- `GET /api/v1/patients/{patient_id}/landmarks`
- `POST /api/v1/patients/{patient_id}/landmarks` → 201
- `PUT /api/v1/patients/{patient_id}/landmarks/{landmark_id}` (partial update)
- `DELETE /api/v1/patients/{patient_id}/landmarks/{landmark_id}` → 204

Cross-patient landmark ids return 404 or 403.

## Devices

### `PUT /api/v1/devices/fcm-token` → 200

```json
{ "token": "fcm-token", "device_id": "optional", "platform": "android" }
```

`platform`: `android` | `ios` | `web`. Duplicate token for the same user is idempotent. Token already owned by another user is reassigned. Response never includes the raw token.

### `DELETE /api/v1/devices/fcm-token` → 204

JSON body `{ "token": "fcm-token" }`. Users can only delete their own tokens.

## Flutter integration

Configure the API base independently per environment (`.env`, `--dart-define`, or flavor). Do not hardcode `localhost` for physical devices. Send JSON with `Content-Type: application/json` and the bearer token on all routes except register, login, health, and ready.
