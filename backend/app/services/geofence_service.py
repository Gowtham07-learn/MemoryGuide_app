from app.models.patient_settings import PatientSettings
from app.utils.geo import haversine_meters


class GeofenceService:
    @staticmethod
    def inside_safe_zone(settings: PatientSettings | None, latitude: float, longitude: float) -> bool | None:
        if (
            settings is None
            or not settings.safe_zone_enabled
            or settings.safe_zone_latitude is None
            or settings.safe_zone_longitude is None
            or settings.safe_zone_radius_meters is None
        ):
            return None
        distance = haversine_meters(
            latitude,
            longitude,
            settings.safe_zone_latitude,
            settings.safe_zone_longitude,
        )
        return distance <= settings.safe_zone_radius_meters
