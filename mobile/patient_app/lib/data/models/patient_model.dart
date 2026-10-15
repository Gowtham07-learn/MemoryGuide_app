class UserModel {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String? phone;
  final bool isActive;
  final String? linkCode;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    required this.isActive,
    this.linkCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'patient',
      fullName: json['full_name']?.toString() ?? 'Patient',
      phone: json['phone']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      linkCode: json['link_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'full_name': fullName,
        'phone': phone,
        'is_active': isActive,
        'link_code': linkCode,
      };
}

class PatientSettingsModel {
  final String patientId;
  final bool trackingEnabled;
  final int locationIntervalSeconds;
  final bool geofenceAlertsEnabled;
  final bool safeZoneEnabled;
  final double? safeZoneLatitude;
  final double? safeZoneLongitude;
  final double safeZoneRadiusMeters;
  final int helpAlertCooldownSeconds;

  const PatientSettingsModel({
    required this.patientId,
    required this.trackingEnabled,
    required this.locationIntervalSeconds,
    required this.geofenceAlertsEnabled,
    required this.safeZoneEnabled,
    this.safeZoneLatitude,
    this.safeZoneLongitude,
    required this.safeZoneRadiusMeters,
    required this.helpAlertCooldownSeconds,
  });

  factory PatientSettingsModel.fromJson(Map<String, dynamic> json) {
    return PatientSettingsModel(
      patientId: json['patient_id']?.toString() ?? '',
      trackingEnabled: json['tracking_enabled'] as bool? ?? true,
      locationIntervalSeconds: (json['location_interval_seconds'] as num?)?.toInt() ?? 60,
      geofenceAlertsEnabled: json['geofence_alerts_enabled'] as bool? ?? true,
      safeZoneEnabled: json['safe_zone_enabled'] as bool? ?? false,
      safeZoneLatitude: (json['safe_zone_latitude'] as num?)?.toDouble(),
      safeZoneLongitude: (json['safe_zone_longitude'] as num?)?.toDouble(),
      safeZoneRadiusMeters: (json['safe_zone_radius_meters'] as num?)?.toDouble() ?? 200.0,
      helpAlertCooldownSeconds: (json['help_alert_cooldown_seconds'] as num?)?.toInt() ?? 60,
    );
  }
}

class PatientStatusModel {
  final String patientId;
  final bool trackingEnabled;
  final Map<String, dynamic>? latestLocation;
  final bool? insideSafeZone;
  final int openAlertCount;
  final bool locationAvailable;

  const PatientStatusModel({
    required this.patientId,
    required this.trackingEnabled,
    this.latestLocation,
    this.insideSafeZone,
    required this.openAlertCount,
    required this.locationAvailable,
  });

  factory PatientStatusModel.fromJson(Map<String, dynamic> json) {
    return PatientStatusModel(
      patientId: json['patient_id']?.toString() ?? '',
      trackingEnabled: json['tracking_enabled'] as bool? ?? true,
      latestLocation: json['latest_location'] as Map<String, dynamic>?,
      insideSafeZone: json['inside_safe_zone'] as bool?,
      openAlertCount: (json['open_alert_count'] as num?)?.toInt() ?? 0,
      locationAvailable: json['location_available'] as bool? ?? false,
    );
  }
}

class LandmarkModel {
  final String id;
  final String patientId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  const LandmarkModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    return LandmarkModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
    );
  }
}

class HelpRequestResultModel {
  final Map<String, dynamic> alert;
  final String notificationStatus;

  const HelpRequestResultModel({
    required this.alert,
    required this.notificationStatus,
  });

  factory HelpRequestResultModel.fromJson(Map<String, dynamic> json) {
    return HelpRequestResultModel(
      alert: json['alert'] as Map<String, dynamic>? ?? {},
      notificationStatus: (json['notification'] as Map<String, dynamic>?)?['status']?.toString() ?? 'skipped',
    );
  }
}
