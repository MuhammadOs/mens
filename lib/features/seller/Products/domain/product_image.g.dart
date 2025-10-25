// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
  id: (json['id'] as num?)?.toInt() ?? 0,
  imageUrl: json['imageUrl'] as String,
  altText: json['altText'] as String?,
  isPrimary: json['isPrimary'] as bool? ?? false,
);

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'altText': instance.altText,
      'isPrimary': instance.isPrimary,
    };
