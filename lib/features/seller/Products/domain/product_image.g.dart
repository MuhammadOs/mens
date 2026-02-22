// GENERATED CODE - DO NOT MODIFY BY HAND
// MANUALLY PATCHED: safe int parsing to handle backends that return numbers as strings

part of 'product_image.dart';

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

/// Safe bool parser: handles bool and String ('true'/'false') from the server
bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
  id: _toInt(json['id']),
  imageUrl: json['imageUrl'] as String,
  altText: json['altText'] as String?,
  isPrimary: _toBool(json['isPrimary']),
);

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'altText': instance.altText,
      'isPrimary': instance.isPrimary,
    };
