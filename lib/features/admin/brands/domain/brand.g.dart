// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brand _$BrandFromJson(Map<String, dynamic> json) => Brand(
  id: (json['id'] as num).toInt(),
  ownerId: (json['ownerId'] as num).toInt(),
  ownerName: json['ownerName'] as String,
  brandName: json['brandName'] as String,
  brandDescription: json['brandDescription'] as String,
  brandImage: json['brandImage'] as String?,
  vat: json['vat'] as String?,
  categoryId: (json['categoryId'] as num).toInt(),
  categoryName: json['categoryName'] as String,
  location: json['location'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BrandToJson(Brand instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'brandName': instance.brandName,
  'brandDescription': instance.brandDescription,
  'brandImage': instance.brandImage,
  'vat': instance.vat,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'location': instance.location,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
