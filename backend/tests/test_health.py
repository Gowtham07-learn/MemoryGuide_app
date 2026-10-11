def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["data"]["status"] == "ok"


def test_validation_error_envelope(client):
    response = client.post("/api/v1/auth/login", json={"email": "not-an-email"})
    assert response.status_code == 422
    body = response.json()
    assert body["success"] is False
    assert body["error"]["code"] == "VALIDATION_ERROR"
    assert isinstance(body["error"]["details"], list)


def test_required_routes_in_openapi(client):
    spec = client.get("/openapi.json")
    assert spec.status_code == 200
    paths = spec.json()["paths"]
    expected = [
        "/health",
        "/api/v1/auth/register",
        "/api/v1/auth/login",
        "/api/v1/auth/me",
        "/api/v1/caregivers/patients",
        "/api/v1/patients/{patient_id}",
        "/api/v1/patients/{patient_id}/settings",
        "/api/v1/patients/{patient_id}/locations",
        "/api/v1/patients/{patient_id}/status",
        "/api/v1/patients/{patient_id}/alerts",
        "/api/v1/patients/{patient_id}/help",
        "/api/v1/alerts/{alert_id}",
        "/api/v1/patients/{patient_id}/landmarks",
        "/api/v1/patients/{patient_id}/landmarks/{landmark_id}",
        "/api/v1/devices/fcm-token",
    ]
    for path in expected:
        assert path in paths, path
