from tests.helpers import auth_header, register_user


def test_register_duplicate_and_delete_token(client):
    user = register_user(client, email="dev@example.com", role="caregiver")
    headers = auth_header(user["access_token"])
    payload = {"token": "fcm-token-value-abc123", "device_id": "pixel-1", "platform": "android"}
    first = client.put("/api/v1/devices/fcm-token", headers=headers, json=payload)
    assert first.status_code == 200
    assert "token" not in first.json()["data"]

    second = client.put("/api/v1/devices/fcm-token", headers=headers, json=payload)
    assert second.status_code == 200
    assert second.json()["data"]["id"] == first.json()["data"]["id"]

    deleted = client.request(
        "DELETE",
        "/api/v1/devices/fcm-token",
        headers=headers,
        json={"token": "fcm-token-value-abc123"},
    )
    assert deleted.status_code == 204


def test_token_reassignment_and_ownership(client):
    first = register_user(client, email="one@example.com", role="caregiver")
    second = register_user(client, email="two@example.com", role="caregiver")
    token = "shared-device-token-xyz"
    client.put(
        "/api/v1/devices/fcm-token",
        headers=auth_header(first["access_token"]),
        json={"token": token, "platform": "ios"},
    )
    reassigned = client.put(
        "/api/v1/devices/fcm-token",
        headers=auth_header(second["access_token"]),
        json={"token": token, "platform": "ios"},
    )
    assert reassigned.status_code == 200

    stolen = client.request(
        "DELETE",
        "/api/v1/devices/fcm-token",
        headers=auth_header(first["access_token"]),
        json={"token": token},
    )
    assert stolen.status_code == 403


def test_firebase_disabled_does_not_block_token_or_help(client):
    patient = register_user(client, email="p@example.com", role="patient")
    registered = client.put(
        "/api/v1/devices/fcm-token",
        headers=auth_header(patient["access_token"]),
        json={"token": "token-without-firebase", "platform": "android"},
    )
    assert registered.status_code == 200
    help_res = client.post(
        f"/api/v1/patients/{patient['user']['id']}/help",
        headers=auth_header(patient["access_token"]),
        json={},
    )
    assert help_res.status_code == 201
    assert help_res.json()["data"]["notification"]["firebase_configured"] is False
    assert help_res.json()["data"]["notification"]["status"] == "skipped"
