from fastapi import APIRouter

from app.api.v1.endpoints import alerts, auth, caregivers, devices, landmarks, locations, patients, settings

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(caregivers.router)
api_router.include_router(patients.router)
api_router.include_router(settings.router)
api_router.include_router(locations.router)
api_router.include_router(alerts.router)
api_router.include_router(landmarks.router)
api_router.include_router(devices.router)
