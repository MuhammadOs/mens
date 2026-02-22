class AdminUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? nationalId;
  final DateTime? birthDate;
  final String role;
  final bool emailConfirmed;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.nationalId,
    this.birthDate,
    required this.role,
    required this.emailConfirmed,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      nationalId: json['nationalId'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      role: json['role'] as String? ?? 'User',
      emailConfirmed: json['emailConfirmed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
