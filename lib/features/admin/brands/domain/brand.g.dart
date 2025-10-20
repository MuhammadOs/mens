// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brand _$BrandFromJson(Map<String, dynamic> json) => Brand(
  id: (json['id'] as num).toInt(),
  brandName: json['brandName'] as String,
  ownerName: json['ownerName'] as String,
  productCount: (json['productCount'] as num).toInt(),
);

Map<String, dynamic> _$BrandToJson(Brand instance) => <String, dynamic>{
  'id': instance.id,
  'brandName': instance.brandName,
  'ownerName': instance.ownerName,
  'productCount': instance.productCount,
};
