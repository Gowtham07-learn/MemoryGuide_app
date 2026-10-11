from tests.helpers import auth_header, linked_pair


def test_geofence_exit_and_enter(client):
    pair = linked_pair(client)
    patient_id = pair["patient_id"]
    caregiver = auth_header(pair["caregiver"]["access_token"])
    patient = auth_header(pair["patient"]["access_token"])

    setup = client.put(
        f"/api/v1/patients/{patient_id}/settings",
        headers=caregiver,
        json={
            "safe_zone_enabled": True,
            "safe_zone_latitude": 12.9716,
            "safe_zone_longitude": 77.5946,
            "safe_zone_radius_meters": 200,
            "geofence_alerts_enabled": True,
        },
    )
    assert setup.status_code == 200

    outside = client.post(
        f"/api/v1/patients/{patient_id}/locations",
        headers=patient,
        json={"latitude": 13.05, "longitude": 77.70},
    )
    assert outside.status_code == 201

    alerts = client.get(f"/api/v1/patients/{patient_id}/alerts", headers=caregiver)
    types = [item["alert_type"] for item in alerts.json()["data"]["items"]]
    assert "geofence_exit" in types

    inside = client.post(
        f"/api/v1/patients/{patient_id}/locations",
        headers=patient,
        json={"latitude": 12.9716, "longitude": 77.5946},
    )
    assert inside.status_code == 201
    alerts = client.get(f"/api/v1/patients/{patient_id}/alerts", headers=caregiver)
    items = alerts.json()["data"]["items"]
    assert any(item["alert_type"] == "geofence_enter" and item["status"] == "open" for item in items)
    assert any(item["alert_type"] == "geofence_exit" and item["status"] == "resolved" for item in items)
