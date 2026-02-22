// GENERATED CODE - DO NOT MODIFY BY HAND
// MANUALLY PATCHED: safe int parsing to handle backends that return numbers as strings

part of 'category.dart';

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

SubCategory _$SubCategoryFromJson(Map<String, dynamic> json) =>
    SubCategory(id: _toInt(json['id']), name: json['name'] as String);

Map<String, dynamic> _$SubCategoryToJson(SubCategory instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: _toInt(json['id']),
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  subCategories: (json['subCategories'] as List<dynamic>)
      .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'subCategories': instance.subCategories,
};
