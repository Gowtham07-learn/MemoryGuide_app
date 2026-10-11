# Firebase Cloud Messaging

Push delivery is optional. The API stores FCM tokens and help-request alerts even when Firebase is not configured.

## Local development and tests

Leave `FIREBASE_CREDENTIALS_FILE` empty. The backend starts normally. Help requests return:

```json
"notification": {
  "attempted": false,
  "delivered_count": 0,
  "status": "skipped",
  "firebase_configured": false
}
```

Automated tests mock the gateway and never send real messages.

## Enabling FCM

1. Create a Firebase project and a service account with FCM permission.
2. Download the JSON key. Do not commit it.
3. Set:

```env
FIREBASE_CREDENTIALS_FILE=/absolute/path/to/serviceAccount.json
FIREBASE_PROJECT_ID=your-project-id
```

4. Clients call `PUT /api/v1/devices/fcm-token` after login with the device FCM token.
5. Help requests notify **active linked caregivers** for that patient.

## Token handling

- Tokens are unique. Re-registering reassigns the token to the current user.
- Users may delete only their own tokens.
- Unregistered/invalid tokens are dropped after a delivery failure.
- Tokens are never written to API responses or application logs.

## Payload

Notification `data` contains `type`, `alert_id`, and `patient_id` so the caregiver app can open the correct record through the API. Precise coordinates are not included in the push payload.
