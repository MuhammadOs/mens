// GENERATED CODE - DO NOT MODIFY BY HAND
// MANUALLY PATCHED: safe int parsing to handle backends that return numbers as strings

part of 'store.dart';

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

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
  id: _toInt(json['id']),
  ownerId: _toInt(json['ownerId']),
  brandName: json['brandName'] as String,
  brandImage: json['brandImage'] as String?,
  brandDescription: json['brandDescription'] as String?,
  vat: json['vat'] as String?,
  categoryId: _toInt(json['categoryId']),
  location: json['location'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'brandName': instance.brandName,
  'brandImage': instance.brandImage,
  'brandDescription': instance.brandDescription,
  'vat': instance.vat,
  'categoryId': instance.categoryId,
  'location': instance.location,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
