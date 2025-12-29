import 'package:json_annotation/json_annotation.dart';

// part 'brand.g.dart';

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

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: _parseInt(json['id']) ?? _parseInt(json['brand_id']) ?? 0,
      ownerId: _parseInt(json['ownerId']) ?? _parseInt(json['owner_id']) ?? 0,
      ownerName: json['ownerName']?.toString() ?? json['owner_name']?.toString() ?? 'Unknown Owner',
      brandName: json['brandName']?.toString() ?? json['brand_name']?.toString() ?? json['name']?.toString() ?? 'Unknown Brand',
      brandDescription: json['brandDescription']?.toString() ?? json['brand_description']?.toString() ?? json['description']?.toString() ?? '',
      brandImage: json['brandImage']?.toString() ?? json['brand_image']?.toString() ?? json['image']?.toString(),
      vat: json['vat']?.toString(),
      categoryId: _parseInt(json['categoryId']) ?? _parseInt(json['category_id']) ?? 0,
      categoryName: json['categoryName']?.toString() ?? json['category_name']?.toString() ?? 'Uncategorized',
      location: json['location']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'brandName': brandName,
    'brandDescription': brandDescription,
    'brandImage': brandImage,
    'vat': vat,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'location': location,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
