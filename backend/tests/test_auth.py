from datetime import timedelta

from tests.helpers import auth_header, register_user

from app.core.security import create_access_token


def test_register_and_login(client):
    registered = register_user(client, email="new@example.com", role="patient")
    assert registered["token_type"] == "bearer"
    assert registered["user"]["email"] == "new@example.com"
    assert registered["user"]["role"] == "patient"
    assert registered["user"]["link_code"]
    login = client.post(
        "/api/v1/auth/login",
        json={"email": "new@example.com", "password": "Password123"},
    )
    assert login.status_code == 200
    assert login.json()["success"] is True
    assert login.json()["data"]["access_token"]


def test_duplicate_registration(client):
    register_user(client, email="dup@example.com")
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "dup@example.com",
            "password": "Password123",
            "full_name": "Other",
            "role": "patient",
        },
    )
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "DUPLICATE_EMAIL"


def test_incorrect_password_does_not_reveal_account(client):
    register_user(client, email="secret@example.com")
    missing = client.post(
        "/api/v1/auth/login", json={"email": "nobody@example.com", "password": "Password123"}
    )
    wrong = client.post(
        "/api/v1/auth/login", json={"email": "secret@example.com", "password": "wrong-pass"}
    )
    assert missing.status_code == 401
    assert wrong.status_code == 401
    assert missing.json()["error"]["code"] == wrong.json()["error"]["code"] == "AUTHENTICATION_FAILED"


def test_reject_admin_self_registration(client):
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "admin@example.com",
            "password": "Password123",
            "full_name": "Admin",
            "role": "admin",
        },
    )
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "VALIDATION_ERROR"


def test_me_and_invalid_tokens(client):
    data = register_user(client, email="me@example.com", role="caregiver")
    ok = client.get("/api/v1/auth/me", headers=auth_header(data["access_token"]))
    assert ok.status_code == 200
    assert ok.json()["data"]["email"] == "me@example.com"

    malformed = client.get("/api/v1/auth/me", headers=auth_header("not-a-jwt"))
    assert malformed.status_code == 401
    assert malformed.json()["error"]["code"] == "TOKEN_INVALID"

    expired = create_access_token(data["user"]["id"], expires_delta=timedelta(seconds=-5))
    expired_res = client.get("/api/v1/auth/me", headers=auth_header(expired))
    assert expired_res.status_code == 401
    assert expired_res.json()["error"]["code"] == "TOKEN_EXPIRED"

    unauth = client.get("/api/v1/auth/me")
    assert unauth.status_code == 401
