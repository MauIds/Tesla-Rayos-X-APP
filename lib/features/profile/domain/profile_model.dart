class ProfileModel {
  final String id;
  final String? email;
  final String? displayName;
  final String role;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        email: json['email'] as String?,
        displayName: json['display_name'] as String?,
        role: (json['role'] as String?) ?? 'client',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get displayInitial {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return '?';
  }

  bool get isAdmin => role == 'admin';
}
