from fastapi.testclient import TestClient


def auth_header(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}


def register_user(
    client: TestClient,
    *,
    email: str,
    password: str = "Password123",
    full_name: str = "Test User",
    role: str = "patient",
    phone: str | None = None,
) -> dict:
    payload = {
        "email": email,
        "password": password,
        "full_name": full_name,
        "role": role,
    }
    if phone is not None:
        payload["phone"] = phone
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201, response.text
    return response.json()["data"]


def linked_pair(client: TestClient) -> dict:
    patient = register_user(
        client, email="patient@example.com", full_name="Pat Patient", role="patient"
    )
    caregiver = register_user(
        client, email="caregiver@example.com", full_name="Cara Caregiver", role="caregiver"
    )
    me = client.get("/api/v1/auth/me", headers=auth_header(patient["access_token"]))
    link_code = me.json()["data"]["link_code"]
    link = client.post(
        "/api/v1/caregivers/patients",
        headers=auth_header(caregiver["access_token"]),
        json={"link_code": link_code},
    )
    assert link.status_code == 201, link.text
    return {
        "patient": patient,
        "caregiver": caregiver,
        "patient_id": patient["user"]["id"],
        "link_code": link_code,
    }
