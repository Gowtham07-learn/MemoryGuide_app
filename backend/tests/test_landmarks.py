from uuid import uuid4

from tests.helpers import auth_header, linked_pair, register_user


def test_landmark_crud(client):
    pair = linked_pair(client)
    headers = auth_header(pair["patient"]["access_token"])
    patient_id = pair["patient_id"]

    created = client.post(
        f"/api/v1/patients/{patient_id}/landmarks",
        headers=headers,
        json={"name": "Home", "latitude": 12.97, "longitude": 77.59, "notes": "Front gate"},
    )
    assert created.status_code == 201
    landmark_id = created.json()["data"]["id"]

    listed = client.get(f"/api/v1/patients/{patient_id}/landmarks", headers=headers)
    assert listed.status_code == 200
    assert len(listed.json()["data"]) == 1

    updated = client.put(
        f"/api/v1/patients/{patient_id}/landmarks/{landmark_id}",
        headers=headers,
        json={"name": "Home gate"},
    )
    assert updated.status_code == 200
    assert updated.json()["data"]["name"] == "Home gate"
    assert updated.json()["data"]["latitude"] == 12.97

    invalid = client.post(
        f"/api/v1/patients/{patient_id}/landmarks",
        headers=headers,
        json={"name": "Bad", "latitude": 99, "longitude": 0},
    )
    assert invalid.status_code == 422

    deleted = client.delete(
        f"/api/v1/patients/{patient_id}/landmarks/{landmark_id}",
        headers=headers,
    )
    assert deleted.status_code == 204


def test_cross_patient_landmark_access(client):
    pair = linked_pair(client)
    other = register_user(client, email="p2@example.com", role="patient")
    created = client.post(
        f"/api/v1/patients/{pair['patient_id']}/landmarks",
        headers=auth_header(pair["patient"]["access_token"]),
        json={"name": "Park", "latitude": 12.9, "longitude": 77.5},
    )
    landmark_id = created.json()["data"]["id"]
    stolen = client.put(
        f"/api/v1/patients/{other['user']['id']}/landmarks/{landmark_id}",
        headers=auth_header(other["access_token"]),
        json={"name": "Stolen"},
    )
    assert stolen.status_code == 404

    other_on_first = client.put(
        f"/api/v1/patients/{pair['patient_id']}/landmarks/{landmark_id}",
        headers=auth_header(other["access_token"]),
        json={"name": "Stolen"},
    )
    assert other_on_first.status_code == 403

    missing = client.delete(
        f"/api/v1/patients/{pair['patient_id']}/landmarks/{uuid4()}",
        headers=auth_header(pair["patient"]["access_token"]),
    )
    assert missing.status_code == 404
