from uuid import uuid4

from tests.helpers import auth_header, linked_pair, register_user


def test_unauthenticated_patient_routes(client):
    patient_id = uuid4()
    assert client.get(f"/api/v1/patients/{patient_id}").status_code == 401
    assert client.get(f"/api/v1/patients/{patient_id}/settings").status_code == 401
    assert client.get(f"/api/v1/patients/{patient_id}/locations").status_code == 401


def test_unrelated_caregiver_cannot_access_patient(client):
    pair = linked_pair(client)
    stranger = register_user(client, email="stranger@example.com", role="caregiver")
    headers = auth_header(stranger["access_token"])
    patient_id = pair["patient_id"]
    assert client.get(f"/api/v1/patients/{patient_id}", headers=headers).status_code == 403
    assert client.get(f"/api/v1/patients/{patient_id}/settings", headers=headers).status_code == 403
    assert client.get(f"/api/v1/patients/{patient_id}/status", headers=headers).status_code == 403
    assert client.get(f"/api/v1/patients/{patient_id}/alerts", headers=headers).status_code == 403


def test_unknown_patient_is_404_not_403(client):
    caregiver = register_user(client, email="c2@example.com", role="caregiver")
    response = client.get(
        f"/api/v1/patients/{uuid4()}",
        headers=auth_header(caregiver["access_token"]),
    )
    assert response.status_code == 404


def test_patient_cannot_access_other_patient(client):
    pair = linked_pair(client)
    other = register_user(client, email="p2@example.com", role="patient")
    response = client.get(
        f"/api/v1/patients/{pair['patient_id']}/settings",
        headers=auth_header(other["access_token"]),
    )
    assert response.status_code == 403
