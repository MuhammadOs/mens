import 'package:json_annotation/json_annotation.dart';

part 'brand.g.dart';

@JsonSerializable()
class Brand {
  final int id;
  final String brandName;
  final String ownerName; // Assuming API provides this
  final int productCount; // Assuming API provides this

  Brand({
    required this.id,
    required this.brandName,
    required this.ownerName,
    required this.productCount,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
  Map<String, dynamic> toJson() => _$BrandToJson(this);
}