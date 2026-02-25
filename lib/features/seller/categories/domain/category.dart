import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? nameAr;
  final int? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Category> subCategories;

  Category({
    required this.id,
    required this.name,
    this.nameAr,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.subCategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Helper to get name based on locale
  String getName(bool isArabic) => (isArabic && nameAr != null) ? nameAr! : name;
}

/// Type alias for backward compatibility or specific leaf-node semantics
typedef SubCategory = Category;