import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart'; // Name of the generated file

@JsonSerializable()
class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) => _$SubCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}