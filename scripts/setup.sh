#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/backend"
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created backend/.env — set SECRET_KEY and DATABASE_URL"
fi
echo "Next: create PostgreSQL database, alembic upgrade head, then uvicorn app.main:app --reload"
echo "Tests: pytest (no PostgreSQL required)"
