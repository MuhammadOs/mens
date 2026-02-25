// GENERATED CODE - DO NOT MODIFY BY HAND
// MANUALLY PATCHED: safe int parsing and recursive Category support

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String)
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  return 0;
}

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: _toInt(json['id']),
  name: json['name'] as String,
  nameAr: json['nameAr'] as String?,
  parentId: json['parentId'] == null ? null : _toInt(json['parentId']),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'parentId': instance.parentId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'subCategories': instance.subCategories,
};
