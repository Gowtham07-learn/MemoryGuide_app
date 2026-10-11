$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location "$root\backend"
python -m venv .venv
& .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
    Write-Host "Created backend/.env — set SECRET_KEY and DATABASE_URL"
}
Write-Host "Next: create PostgreSQL database, alembic upgrade head, then uvicorn app.main:app --reload"
Write-Host "Tests: pytest (no PostgreSQL required)"
