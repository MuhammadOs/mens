import 'package:json_annotation/json_annotation.dart';

part 'brand.g.dart';

@JsonSerializable()
class Brand {
  final int id;
  final int ownerId;
  final String ownerName;
  final String brandName;
  final String brandDescription;
  final String? brandImage;
  final String? vat;
  final int categoryId;
  final String categoryName;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Brand({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.brandName,
    required this.brandDescription,
    this.brandImage,
    this.vat,
    required this.categoryId,
    required this.categoryName,
    required this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
  Map<String, dynamic> toJson() => _$BrandToJson(this);
}
