from tests.helpers import auth_header, linked_pair


def test_record_and_paginate_locations(client):
    pair = linked_pair(client)
    patient_headers = auth_header(pair["patient"]["access_token"])
    caregiver_headers = auth_header(pair["caregiver"]["access_token"])
    patient_id = pair["patient_id"]

    status = client.get(f"/api/v1/patients/{patient_id}/status", headers=caregiver_headers)
    assert status.status_code == 200
    assert status.json()["data"]["latest_location"] is None
    assert status.json()["data"]["location_available"] is False

    created = client.post(
        f"/api/v1/patients/{patient_id}/locations",
        headers=patient_headers,
        json={"latitude": 12.97, "longitude": 77.59, "accuracy_meters": 8},
    )
    assert created.status_code == 201

    invalid = client.post(
        f"/api/v1/patients/{patient_id}/locations",
        headers=patient_headers,
        json={"latitude": 200, "longitude": 77.59},
    )
    assert invalid.status_code == 422

    for i in range(5):
        client.post(
            f"/api/v1/patients/{patient_id}/locations",
            headers=patient_headers,
            json={"latitude": 12.9 + i * 0.01, "longitude": 77.59},
        )

    page = client.get(
        f"/api/v1/patients/{patient_id}/locations",
        headers=caregiver_headers,
        params={"page": 1, "page_size": 3},
    )
    assert page.status_code == 200
    data = page.json()["data"]
    assert len(data["items"]) == 3
    assert data["pagination"]["total"] == 6
    assert data["pagination"]["page_size"] == 3

    caregiver_write = client.post(
        f"/api/v1/patients/{patient_id}/locations",
        headers=caregiver_headers,
        json={"latitude": 12.97, "longitude": 77.59},
    )
    assert caregiver_write.status_code == 403
