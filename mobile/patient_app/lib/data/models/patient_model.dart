class PatientModel {
  final String id;
  final String name;
  final String? avatarUrl;

  const PatientModel({required this.id, required this.name, this.avatarUrl});

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      name: json['full_name'] ?? 'Patient',
      avatarUrl: json['avatar_url'],
    );
  }
}
