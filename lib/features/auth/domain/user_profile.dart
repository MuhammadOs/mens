import 'package:json_annotation/json_annotation.dart';
import 'store.dart'; // ✅ Import the new Store model

part 'user_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfile {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phoneNumber;
  final String role;
  final bool emailConfirmed;
  final DateTime createdAt;
  final Store? store;
  final String? nationalId;
  final DateTime? birthDate;
  UserProfile({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phoneNumber,
    this.nationalId,
    this.birthDate,
    required this.role,
    required this.emailConfirmed,
    required this.createdAt,
    this.store,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
