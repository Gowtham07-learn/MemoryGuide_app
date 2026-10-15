import '../../core/network/api_client.dart';
import '../models/patient_model.dart';
import 'auth_repository.dart';

class PatientRepository {
  final ApiClient apiClient;
  final AuthRepository authRepository;

  PatientRepository({
    required this.apiClient,
    required this.authRepository,
  });

  String get _patientId {
    final user = authRepository.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('Patient is not authenticated');
    }
    return user.id;
  }

  /// Sends a verified SOS Help Request to POST /api/v1/patients/{patient_id}/help
  Future<HelpRequestResultModel> triggerHelp({
    String? message,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      if (message != null && message.isNotEmpty) 'message': message,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    final response = await apiClient.post('/patients/$_patientId/help', body);
    if (response is Map<String, dynamic>) {
      return HelpRequestResultModel.fromJson(response);
    }
    return HelpRequestResultModel(
      alert: response is Map<String, dynamic> ? response : {},
      notificationStatus: 'skipped',
    );
  }

  /// Deprecated backwards compatibility placeholder.
  @Deprecated('Use triggerHelp(...) instead.')
  Future<void> triggerSos() async {
    await triggerHelp();
  }

  /// Retrieves patient status (latest location, inside safe zone, open alerts)
  Future<PatientStatusModel> fetchStatus() async {
    final response = await apiClient.get('/patients/$_patientId/status');
    return PatientStatusModel.fromJson(response as Map<String, dynamic>);
  }

  /// Retrieves safe zone and monitoring settings
  Future<PatientSettingsModel> fetchSettings() async {
    final response = await apiClient.get('/patients/$_patientId/settings');
    return PatientSettingsModel.fromJson(response as Map<String, dynamic>);
  }

  /// Updates safe zone or tracking settings
  Future<PatientSettingsModel> updateSettings(Map<String, dynamic> delta) async {
    final response = await apiClient.put('/patients/$_patientId/settings', delta);
    return PatientSettingsModel.fromJson(response as Map<String, dynamic>);
  }

  /// Records a new GPS location reading
  Future<Map<String, dynamic>> recordLocation({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    double? altitudeMeters,
    double? speedMps,
    double? headingDegrees,
  }) async {
    final body = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (altitudeMeters != null) 'altitude_meters': altitudeMeters,
      if (speedMps != null) 'speed_mps': speedMps,
      if (headingDegrees != null) 'heading_degrees': headingDegrees,
    };
    final response = await apiClient.post('/patients/$_patientId/locations', body);
    return response is Map<String, dynamic> ? response : {};
  }

  /// Retrieves the list of landmarks
  Future<List<LandmarkModel>> fetchLandmarks() async {
    final response = await apiClient.get('/patients/$_patientId/landmarks');
    if (response is List) {
      return response
          .map((item) => LandmarkModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
