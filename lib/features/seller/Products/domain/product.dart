import 'package:json_annotation/json_annotation.dart';
import 'package:mens/features/seller/Products/domain/product_image.dart';

// part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;
  final int storeId;
  final String? storeName;
  final List<ProductImage> images;
  final String? material;
  final DateTime? createdAt;
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
    this.storeName,
    required this.images,
    this.material,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']) ?? _parseInt(json['product_id']) ?? 0,
      name:
          json['name']?.toString() ??
          json['product_name']?.toString() ??
          'Unnamed Product',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']) ?? 0.0,
      stockQuantity:
          _parseInt(json['stockQuantity']) ??
          _parseInt(json['stock_quantity']) ??
          _parseInt(json['quantity']) ??
          _parseInt(json['stock']) ??
          _parseInt(json['StockQuantity']) ??
          0,
      categoryId:
          _parseInt(json['categoryId']) ?? _parseInt(json['category_id']) ?? 0,
      categoryName:
          json['categoryName']?.toString() ??
          json['category_name']?.toString() ??
          'Uncategorized',
      subCategoryId:
          _parseInt(json['subCategoryId']) ??
          _parseInt(json['sub_category_id']) ??
          0,
      subCategoryName:
          json['subCategoryName']?.toString() ??
          json['sub_category_name']?.toString() ??
          '',
      storeId: _parseInt(json['storeId']) ?? _parseInt(json['store_id']) ?? 0,
      storeName:
          json['storeName']?.toString() ?? json['store_name']?.toString(),
      material: json['material']?.toString(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'stockQuantity': stockQuantity,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'subCategoryId': subCategoryId,
    'subCategoryName': subCategoryName,
    'storeId': storeId,
    'storeName': storeName,
    'material': material,
    'images': images.map((e) => e.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

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
    String? material,
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
      material: material ?? this.material,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
