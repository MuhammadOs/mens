import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart'; // Name of the generated file

@JsonSerializable()
class Store {
  final int id;
  final String brandName;
  final String? brandImage;
  final String? brandDescription;
  final String? vat;
  final int categoryId;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Store({
    required this.id,
    required this.brandName,
    this.brandImage,
    this.brandDescription,
    this.vat,
    required this.categoryId,
    this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);
}