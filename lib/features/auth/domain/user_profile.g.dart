// GENERATED CODE - DO NOT MODIFY BY HAND
// MANUALLY PATCHED: safe int parsing to handle backends that return numbers as strings

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

/// Safe int parser: handles int, double, and String values from the server
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String)
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  return 0;
}

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  userId: _toInt(json['userId']),
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  nationalId: json['nationalId'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  role: json['role'] as String,
  emailConfirmed: json['emailConfirmed'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  store: json['store'] == null
      ? null
      : Store.fromJson(json['store'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'nationalId': instance.nationalId,
      'birthDate': instance.birthDate?.toIso8601String(),
      'role': instance.role,
      'emailConfirmed': instance.emailConfirmed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'store': instance.store?.toJson(),
    };
