import 'package:json_annotation/json_annotation.dart';
import 'package:mens/features/seller/Products/domain/product_image.dart';

part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'stockQuantity')
  final int? stockQuantity;
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;
  final int storeId;
  final String? storeName;
  final List<ProductImage> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.storeId,
    this.storeName,
    required this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  /// Get the primary image URL, or the first image if no primary is set
  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primaryImage = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    );
    return primaryImage.imageUrl;
  }

  /// Get all image URLs as a list (for backward compatibility)
  List<String> get imageUrls => images.map((img) => img.imageUrl).toList();

  /// Get the first image URL (for backward compatibility)
  String? get firstImageUrl => images.isNotEmpty ? images.first.imageUrl : null;

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
    List<ProductImage>? images,
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
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
