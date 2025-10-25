import 'package:json_annotation/json_annotation.dart';

part 'product_image.g.dart';

@JsonSerializable()
class ProductImage {
  @JsonKey(defaultValue: 0)
  final int id; // 0 for new images, actual id for existing ones
  final String imageUrl;
  final String? altText; // Optional alt text for accessibility
  final bool isPrimary; // Indicates if this is the primary/main image

  ProductImage({
    this.id = 0,
    required this.imageUrl,
    this.altText,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);

  Map<String, dynamic> toJson() => _$ProductImageToJson(this);

  ProductImage copyWith({
    int? id,
    String? imageUrl,
    String? altText,
    bool? isPrimary,
  }) {
    return ProductImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      altText: altText ?? this.altText,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
