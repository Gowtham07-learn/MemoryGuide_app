from tests.helpers import auth_header, linked_pair


def test_get_and_partial_update_settings(client):
    pair = linked_pair(client)
    headers = auth_header(pair["caregiver"]["access_token"])
    patient_id = pair["patient_id"]
    original = client.get(f"/api/v1/patients/{patient_id}/settings", headers=headers)
    assert original.status_code == 200
    assert original.json()["data"]["tracking_enabled"] is True

    updated = client.put(
        f"/api/v1/patients/{patient_id}/settings",
        headers=headers,
        json={"location_interval_seconds": 120},
    )
    assert updated.status_code == 200
    body = updated.json()["data"]
    assert body["location_interval_seconds"] == 120
    assert body["tracking_enabled"] is True

    enabling = client.put(
        f"/api/v1/patients/{patient_id}/settings",
        headers=headers,
        json={"safe_zone_enabled": True},
    )
    assert enabling.status_code == 422
