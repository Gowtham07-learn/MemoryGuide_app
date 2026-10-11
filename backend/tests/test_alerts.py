from app.services.notification_service import NotificationService
from tests.helpers import auth_header, linked_pair, register_user


class FailingGateway:
    def send_to_tokens(self, tokens, title, body, data):
        raise RuntimeError("FCM unavailable")


def test_help_request_lifecycle(client):
    pair = linked_pair(client)
    patient_id = pair["patient_id"]
    patient = auth_header(pair["patient"]["access_token"])
    caregiver = auth_header(pair["caregiver"]["access_token"])

    created = client.post(
        f"/api/v1/patients/{patient_id}/help",
        headers=patient,
        json={"message": "Need assistance", "latitude": 12.97, "longitude": 77.59},
    )
    assert created.status_code == 201
    body = created.json()["data"]
    assert body["alert"]["alert_type"] == "help_request"
    assert body["alert"]["status"] == "open"
    assert body["notification"]["status"] == "skipped"
    alert_id = body["alert"]["id"]

    listed = client.get(f"/api/v1/patients/{patient_id}/alerts", headers=caregiver)
    assert listed.json()["data"]["pagination"]["total"] >= 1

    ack = client.patch(f"/api/v1/alerts/{alert_id}", headers=caregiver, json={"status": "acknowledged"})
    assert ack.status_code == 200
    assert ack.json()["data"]["status"] == "acknowledged"

    invalid = client.patch(f"/api/v1/alerts/{alert_id}", headers=caregiver, json={"status": "open"})
    assert invalid.status_code == 422

    resolved = client.patch(f"/api/v1/alerts/{alert_id}", headers=caregiver, json={"status": "resolved"})
    assert resolved.status_code == 200
    assert resolved.json()["data"]["status"] == "resolved"


def test_duplicate_help_request(client):
    pair = linked_pair(client)
    patient = auth_header(pair["patient"]["access_token"])
    patient_id = pair["patient_id"]
    first = client.post(f"/api/v1/patients/{patient_id}/help", headers=patient, json={})
    assert first.status_code == 201
    second = client.post(f"/api/v1/patients/{patient_id}/help", headers=patient, json={})
    assert second.status_code == 409
    assert second.json()["error"]["code"] == "DUPLICATE_HELP_REQUEST"


def test_caregiver_cannot_create_help(client):
    pair = linked_pair(client)
    response = client.post(
        f"/api/v1/patients/{pair['patient_id']}/help",
        headers=auth_header(pair["caregiver"]["access_token"]),
        json={},
    )
    assert response.status_code == 403


def test_notification_failure_does_not_roll_back_help(client, monkeypatch):
    pair = linked_pair(client)
    client.put(
        "/api/v1/devices/fcm-token",
        headers=auth_header(pair["caregiver"]["access_token"]),
        json={"token": "caregiver-device-token-123", "platform": "android"},
    )

    original_init = NotificationService.__init__

    def patched_init(self, db, gateway=None):
        original_init(self, db, gateway=FailingGateway())
        self.firebase_configured = True

    monkeypatch.setattr(NotificationService, "__init__", patched_init)

    created = client.post(
        f"/api/v1/patients/{pair['patient_id']}/help",
        headers=auth_header(pair["patient"]["access_token"]),
        json={"message": "Emergency"},
    )
    assert created.status_code == 201
    data = created.json()["data"]
    assert data["alert"]["id"]
    assert data["notification"]["status"] == "failed"
    assert data["alert"]["notification_status"] == "failed"

    listed = client.get(
        f"/api/v1/patients/{pair['patient_id']}/alerts",
        headers=auth_header(pair["caregiver"]["access_token"]),
    )
    assert listed.json()["data"]["pagination"]["total"] >= 1


def test_unrelated_user_cannot_patch_alert(client):
    pair = linked_pair(client)
    created = client.post(
        f"/api/v1/patients/{pair['patient_id']}/help",
        headers=auth_header(pair["patient"]["access_token"]),
        json={},
    )
    alert_id = created.json()["data"]["alert"]["id"]
    stranger = register_user(client, email="other@example.com", role="caregiver")
    response = client.patch(
        f"/api/v1/alerts/{alert_id}",
        headers=auth_header(stranger["access_token"]),
        json={"status": "acknowledged"},
    )
    assert response.status_code == 403
