import '../../core/network/api_client.dart';

/// Repository responsible for patient-related backend communication.
///
/// NOTE on SOS / Help Alert Integration:
/// The previous placeholder method [triggerSos] targeted '/alerts/sos', which
/// does not exist in the backend API contract.
///
/// The verified backend contract (see docs/api/api_contract.md and
/// backend/app/api/v1/endpoints/alerts.py) specifies:
/// - Endpoint: POST /api/v1/patients/{patient_id}/help
/// - Authentication: Bearer token (Patient role required)
/// - Request Body: { "message": String?, "latitude": double?, "longitude": double? }
/// - Response (201): SuccessResponse<HelpRequestResult> containing alert data
///   and notification dispatch outcome (status: 'skipped' | 'no_devices' | 'sent' | 'partial' | 'failed').
///
/// Full integration is pending patient authentication session management
/// and active patient_id context. Until auth tokens and active patient session
/// are wired into the mobile client, the SOS feature operates in demonstration mode.
class PatientRepository {
  final ApiClient apiClient;

  PatientRepository(this.apiClient);

  /// Deprecated placeholder targeting non-existent route.
  ///
  /// Do not use in production until authenticated patient session is established.
  @Deprecated(
      'Use authenticated POST /api/v1/patients/{patient_id}/help when session is available.')
  Future<void> triggerSos() async {
    // Intentionally kept uncalled by EmergencySosButton until patient session is plumbed.
    await apiClient.post('/alerts/sos', {});
  }
}
