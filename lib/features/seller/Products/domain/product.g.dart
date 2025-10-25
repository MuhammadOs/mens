// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  stockQuantity: (json['stockQuantity'] as num?)?.toInt(),
  categoryId: (json['categoryId'] as num).toInt(),
  categoryName: json['categoryName'] as String,
  subCategoryId: (json['subCategoryId'] as num).toInt(),
  subCategoryName: json['subCategoryName'] as String,
  storeId: (json['storeId'] as num).toInt(),
  storeName: json['storeName'] as String?,
  images: (json['images'] as List<dynamic>)
      .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'stockQuantity': instance.stockQuantity,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'subCategoryId': instance.subCategoryId,
  'subCategoryName': instance.subCategoryName,
  'storeId': instance.storeId,
  'storeName': instance.storeName,
  'images': instance.images.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
