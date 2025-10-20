// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
  id: (json['id'] as num).toInt(),
  ownerId: (json['ownerId'] as num).toInt(),
  brandName: json['brandName'] as String,
  brandImage: json['brandImage'] as String?,
  brandDescription: json['brandDescription'] as String?,
  vat: json['vat'] as String?,
  categoryId: (json['categoryId'] as num).toInt(),
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
