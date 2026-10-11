# MemoryGuide backend

FastAPI service for the patient and caregiver apps.

## Requirements

- Python 3.11+
- PostgreSQL 14+ for local/production data
- Optional Firebase service account for push notifications

## Setup

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
# Unix: source .venv/bin/activate
pip install -r requirements.txt
copy .env.example .env   # Windows
# cp .env.example .env   # Unix
```

Set `SECRET_KEY` and `DATABASE_URL` in `.env`. Do not use the example secret in production.

Create the database, then migrate:

```bash
alembic upgrade head
python scripts/seed_dev.py   # optional, development only
```

## Run

From the `backend` directory:

```bash
uvicorn app.main:app --reload
```

Verify:

- `GET http://127.0.0.1:8000/health`
- `GET http://127.0.0.1:8000/docs`

## Tests

Tests use an isolated in-memory SQLite database and do not require PostgreSQL or Firebase.

```bash
cd backend
pytest
```

## Admin user

```bash
python scripts/create_admin.py --email admin@example.com --password 'choose-a-strong-password'
```

## Flutter API base URL

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://127.0.0.1:8000`
- Physical device: `http://<your-computer-LAN-IP>:8000`
