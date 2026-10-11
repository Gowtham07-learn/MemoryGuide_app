from tests.helpers import auth_header, linked_pair, register_user


def test_link_workflow_and_list(client):
    pair = linked_pair(client)
    listed = client.get(
        "/api/v1/caregivers/patients",
        headers=auth_header(pair["caregiver"]["access_token"]),
    )
    assert listed.status_code == 200
    items = listed.json()["data"]
    assert len(items) == 1
    assert items[0]["patient"]["id"] == pair["patient_id"]

    detail = client.get(
        f"/api/v1/patients/{pair['patient_id']}",
        headers=auth_header(pair["caregiver"]["access_token"]),
    )
    assert detail.status_code == 200
    assert detail.json()["data"]["link_code"] is None

    own = client.get(
        f"/api/v1/patients/{pair['patient_id']}",
        headers=auth_header(pair["patient"]["access_token"]),
    )
    assert own.json()["data"]["link_code"] == pair["link_code"]


def test_invalid_and_duplicate_link(client):
    caregiver = register_user(client, email="c@example.com", role="caregiver")
    missing = client.post(
        "/api/v1/caregivers/patients",
        headers=auth_header(caregiver["access_token"]),
        json={"link_code": "ZZZZZZZZ"},
    )
    assert missing.status_code == 404

    pair = linked_pair(client)
    again = client.post(
        "/api/v1/caregivers/patients",
        headers=auth_header(pair["caregiver"]["access_token"]),
        json={"link_code": pair["link_code"]},
    )
    assert again.status_code == 409
    assert again.json()["error"]["code"] == "ALREADY_LINKED"


def test_patient_cannot_use_link_endpoint(client):
    patient = register_user(client, email="p@example.com", role="patient")
    response = client.post(
        "/api/v1/caregivers/patients",
        headers=auth_header(patient["access_token"]),
        json={"link_code": "ABCDEF12"},
    )
    assert response.status_code == 403
