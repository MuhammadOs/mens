import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'stockQuantity')
  final int stockQuantity;
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;
  final int storeId;
  final String? storeName;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.storeId,
    this.storeName, // ✅ Made nullable
    required this.imageUrls,
    required this.createdAt, // ✅ ADDED
    this.updatedAt, // ✅ ADDED
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  String? get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  // ✅ ADD COPYWITH METHOD
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    int? categoryId,
    String? categoryName,
    int? subCategoryId,
    String? subCategoryName,
    int? storeId,
    String? storeName,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
