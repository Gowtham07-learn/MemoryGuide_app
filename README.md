# MemoryGuide

## Project Structure

```text
MemoryGuide/
│
├── mobile/
│   ├── patient_app/
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── app.dart
│   │   │   ├── core/
│   │   │   │   ├── config/
│   │   │   │   ├── constants/
│   │   │   │   ├── errors/
│   │   │   │   ├── network/
│   │   │   │   ├── routing/
│   │   │   │   ├── theme/
│   │   │   │   └── utils/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── datasources/
│   │   │   │   ├── repositories/
│   │   │   │   └── services/
│   │   │   ├── features/
│   │   │   │   ├── authentication/
│   │   │   │   ├── home/
│   │   │   │   ├── location/
│   │   │   │   ├── safe_zones/
│   │   │   │   ├── landmarks/
│   │   │   │   ├── help/
│   │   │   │   ├── notifications/
│   │   │   │   └── profile/
│   │   │   └── shared/
│   │   │       ├── widgets/
│   │   │       └── components/
│   │   ├── test/
│   │   ├── assets/
│   │   │   ├── images/
│   │   │   ├── icons/
│   │   │   └── fonts/
│   │   ├── android/
│   │   ├── ios/
│   │   ├── pubspec.yaml
│   │   └── .env.example
│   │
│   └── caregiver_app/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app.dart
│       │   ├── core/
│       │   │   ├── config/
│       │   │   ├── constants/
│       │   │   ├── errors/
│       │   │   ├── network/
│       │   │   ├── routing/
│       │   │   ├── theme/
│       │   │   └── utils/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   ├── datasources/
│       │   │   ├── repositories/
│       │   │   └── services/
│       │   ├── features/
│       │   │   ├── authentication/
│       │   │   ├── dashboard/
│       │   │   ├── patients/
│       │   │   ├── live_location/
│       │   │   ├── location_history/
│       │   │   ├── safe_zones/
│       │   │   ├── alerts/
│       │   │   ├── landmarks/
│       │   │   ├── notifications/
│       │   │   └── profile/
│       │   └── shared/
│       │       ├── widgets/
│       │       └── components/
│       ├── test/
│       ├── assets/
│       ├── android/
│       ├── ios/
│       ├── pubspec.yaml
│       └── .env.example
│
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   ├── security.py
│   │   │   ├── permissions.py
│   │   │   └── logging.py
│   │   ├── api/
│   │   │   ├── deps.py
│   │   │   └── v1/
│   │   │       ├── router.py
│   │   │       └── endpoints/
│   │   │           ├── auth.py
│   │   │           ├── caregivers.py
│   │   │           ├── patients.py
│   │   │           ├── settings.py
│   │   │           ├── locations.py
│   │   │           ├── alerts.py
│   │   │           ├── landmarks.py
│   │   │           └── devices.py
│   │   ├── models/
│   │   │   ├── user.py
│   │   │   ├── caregiver_patient.py
│   │   │   ├── patient_settings.py
│   │   │   ├── location.py
│   │   │   ├── safety_event.py
│   │   │   ├── device_token.py
│   │   │   └── landmark.py
│   │   ├── schemas/
│   │   │   ├── auth.py
│   │   │   ├── user.py
│   │   │   ├── relationship.py
│   │   │   ├── settings.py
│   │   │   ├── location.py
│   │   │   ├── alert.py
│   │   │   ├── landmark.py
│   │   │   └── device.py
│   │   ├── services/
│   │   │   ├── auth_service.py
│   │   │   ├── relationship_service.py
│   │   │   ├── location_service.py
│   │   │   ├── geofence_service.py
│   │   │   ├── alert_service.py
│   │   │   ├── landmark_service.py
│   │   │   └── notification_service.py
│   │   ├── repositories/
│   │   │   ├── user_repository.py
│   │   │   ├── location_repository.py
│   │   │   └── alert_repository.py
│   │   ├── db/
│   │   │   ├── session.py
│   │   │   └── base.py
│   │   └── utils/
│   │       ├── geo.py
│   │       └── time.py
│   │
│   ├── alembic/
│   │   ├── env.py
│   │   ├── script.py.mako
│   │   └── versions/
│   ├── tests/
│   │   ├── conftest.py
│   │   ├── test_auth.py
│   │   ├── test_relationships.py
│   │   ├── test_settings.py
│   │   ├── test_locations.py
│   │   ├── test_geofencing.py
│   │   ├── test_alerts.py
│   │   ├── test_landmarks.py
│   │   └── test_authorization.py
│   ├── scripts/
│   │   └── create_admin.py
│   ├── .env.example
│   ├── .gitignore
│   ├── alembic.ini
│   ├── pyproject.toml
│   └── README.md
│
├── database/
│   ├── schema/
│   │   └── memoryguide_schema.sql
│   ├── seeds/
│   │   └── development_seed.sql
│   └── documentation/
│       └── database_schema.md
│
├── docs/
│   ├── api/
│   │   └── api_contract.md
│   ├── architecture/
│   │   └── system_architecture.md
│   └── diagrams/
│
├── firebase/
│   └── README.md
│
├── scripts/
│   ├── setup.sh
│   └── setup.ps1
│
├── .gitignore
├── .editorconfig
└── README.md
```

## API Endpoints

**Base Path:** `/api/v1`

### Health

| Method | Endpoint  |
| ------ | --------- |
| GET    | `/health` |

### Authentication

| Method | Endpoint                |
| ------ | ----------------------- |
| POST   | `/api/v1/auth/register` |
| POST   | `/api/v1/auth/login`    |
| GET    | `/api/v1/auth/me`       |

### Caregiver–Patient Management

| Method | Endpoint                        |
| ------ | ------------------------------- |
| POST   | `/api/v1/caregivers/patients`   |
| GET    | `/api/v1/caregivers/patients`   |
| GET    | `/api/v1/patients/{patient_id}` |

### Patient Settings and Safe Zones

| Method | Endpoint                                 |
| ------ | ---------------------------------------- |
| GET    | `/api/v1/patients/{patient_id}/settings` |
| PUT    | `/api/v1/patients/{patient_id}/settings` |

### Location Tracking

| Method | Endpoint                                  |
| ------ | ----------------------------------------- |
| POST   | `/api/v1/patients/{patient_id}/locations` |
| GET    | `/api/v1/patients/{patient_id}/status`    |
| GET    | `/api/v1/patients/{patient_id}/locations` |

### Alerts and Help Requests

| Method | Endpoint                               |
| ------ | -------------------------------------- |
| GET    | `/api/v1/patients/{patient_id}/alerts` |
| POST   | `/api/v1/patients/{patient_id}/help`   |
| PATCH  | `/api/v1/alerts/{alert_id}`            |

### Landmark Management

| Method | Endpoint                                                |
| ------ | ------------------------------------------------------- |
| GET    | `/api/v1/patients/{patient_id}/landmarks`               |
| POST   | `/api/v1/patients/{patient_id}/landmarks`               |
| PUT    | `/api/v1/patients/{patient_id}/landmarks/{landmark_id}` |
| DELETE | `/api/v1/patients/{patient_id}/landmarks/{landmark_id}` |

### Device and Push Notification Management

| Method | Endpoint                    |
| ------ | --------------------------- |
| PUT    | `/api/v1/devices/fcm-token` |
| DELETE | `/api/v1/devices/fcm-token` |

```
```
