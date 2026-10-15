import '../../core/network/api_client.dart';
import '../models/caregiver_models.dart';

class CaregiverRepository {
  final ApiClient apiClient;

  CaregiverRepository(this.apiClient);

  /// Retrieves list of all active linked patients for the authenticated caregiver
  Future<List<LinkedPatient>> listLinkedPatients() async {
    final response = await apiClient.get('/caregivers/patients');
    if (response is List) {
      return response
          .map((item) => LinkedPatient.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Links a patient using their unique link code
  Future<LinkedPatient> linkPatient(String linkCode) async {
    final response = await apiClient.post('/caregivers/patients', {
      'link_code': linkCode.trim().toUpperCase(),
    });
    return LinkedPatient.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves full profile details of a linked patient
  Future<PatientSummary> getPatient(String patientId) async {
    final response = await apiClient.get('/patients/$patientId');
    return PatientSummary.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves current status, latest location, and safe-zone compliance
  Future<PatientStatus> getPatientStatus(String patientId) async {
    final response = await apiClient.get('/patients/$patientId/status');
    return PatientStatus.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves paginated location history
  Future<List<Map<String, dynamic>>> getPatientLocations(
    String patientId, {
    int page = 1,
    int pageSize = 20,
    DateTime? since,
    DateTime? until,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (since != null) 'since': since.toIso8601String(),
      if (until != null) 'until': until.toIso8601String(),
    };
    final response = await apiClient.get(
      '/patients/$patientId/locations',
      queryParams: query,
    );
    if (response is Map<String, dynamic> && response['items'] is List) {
      return List<Map<String, dynamic>>.from(response['items']);
    }
    return [];
  }

  /// Retrieves safety alerts (Help requests and geofence exit alerts)
  Future<List<AlertItem>> getPatientAlerts(
    String patientId, {
    String? status,
    String? alertType,
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (status != null) query['status'] = status;
    if (alertType != null) query['alert_type'] = alertType;
    final response = await apiClient.get(
      '/patients/$patientId/alerts',
      queryParams: query,
    );
    if (response is Map<String, dynamic> && response['items'] is List) {
      return (response['items'] as List)
          .map((item) => AlertItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Acknowledges or resolves an alert
  Future<AlertItem> patchAlert(String alertId, String newStatus) async {
    final response = await apiClient.patch(
      '/alerts/$alertId',
      {'status': newStatus},
    );
    return AlertItem.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves patient settings and safe-zone configuration
  Future<PatientSettings> getPatientSettings(String patientId) async {
    final response = await apiClient.get('/patients/$patientId/settings');
    return PatientSettings.fromJson(response as Map<String, dynamic>);
  }

  /// Updates safe-zone radius, center coordinates, or tracking parameters
  Future<PatientSettings> updatePatientSettings(
    String patientId,
    Map<String, dynamic> delta,
  ) async {
    final response = await apiClient.put('/patients/$patientId/settings', delta);
    return PatientSettings.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves patient landmarks
  Future<List<LandmarkItem>> getLandmarks(String patientId) async {
    final response = await apiClient.get('/patients/$patientId/landmarks');
    if (response is List) {
      return response
          .map((item) => LandmarkItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Creates a new landmark for a patient
  Future<LandmarkItem> createLandmark({
    required String patientId,
    required String name,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final response = await apiClient.post('/patients/$patientId/landmarks', {
      'name': name.trim(),
      'latitude': latitude,
      'longitude': longitude,
      if (description != null && description.isNotEmpty)
        'description': description.trim(),
    });
    return LandmarkItem.fromJson(response as Map<String, dynamic>);
  }

  /// Deletes a landmark
  Future<void> deleteLandmark(String patientId, String landmarkId) async {
    await apiClient.delete('/patients/$patientId/landmarks/$landmarkId');
  }
}
