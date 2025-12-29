import 'package:json_annotation/json_annotation.dart';

part 'order_models.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderRequest {
  final int storeId;
  final List<OrderItemRequest> items;
  final String paymentMethod;
  final int? addressId;
  final String shippingAddress;
  final String notes;

  OrderRequest({
    required this.storeId,
    required this.items,
    required this.paymentMethod,
    this.addressId,
    required this.shippingAddress,
    required this.notes,
  });

  Map<String, dynamic> toJson() => _$OrderRequestToJson(this);

  factory OrderRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderRequestFromJson(json);
}

@JsonSerializable()
class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => _$OrderItemRequestToJson(this);

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderItemRequestFromJson(json);
}

@JsonSerializable()
class OrderResponse {
  final int id;
  @JsonKey(defaultValue: 0)
  final int userId;
  final String? customerName;
  @JsonKey(defaultValue: 0)
  final int storeId;
  final String? storeName;
  final DateTime? orderDate;
  @JsonKey(defaultValue: 0.0)
  final double totalAmount;
  @JsonKey(defaultValue: 'Unknown')
  final String status;
  @JsonKey(defaultValue: 'Unknown')
  final String paymentMethod;
  @JsonKey(defaultValue: 0)
  final int addressId;
  final OrderAddress? address;
  final String? shippingAddress;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItemResponse> items;

  OrderResponse({
    required this.id,
    required this.userId,
    this.customerName,
    required this.storeId,
    this.storeName,
    this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.addressId,
    this.address,
    this.shippingAddress,
    this.notes,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
}

@JsonSerializable()
class OrderAddress {
  final int id;
  @JsonKey(defaultValue: '')
  final String city;
  @JsonKey(defaultValue: '')
  final String street;
  @JsonKey(defaultValue: '')
  final String buildingNo;
  @JsonKey(defaultValue: '')
  final String floorNo;
  @JsonKey(defaultValue: '')
  final String flatNo;
  final String? notes;

  OrderAddress({
    required this.id,
    required this.city,
    required this.street,
    required this.buildingNo,
    required this.floorNo,
    required this.flatNo,
    this.notes,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) =>
      _$OrderAddressFromJson(json);
}

@JsonSerializable()
class OrderItemResponse {
  final int id;
  @JsonKey(defaultValue: 0)
  final int productId;
  @JsonKey(defaultValue: 'Unknown Product')
  final String productName;
  final String? productImage;
  @JsonKey(defaultValue: 0)
  final int quantity;
  @JsonKey(defaultValue: 0.0)
  final double unitPrice;
  @JsonKey(defaultValue: 0.0)
  final double subtotal;

  OrderItemResponse({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderItemResponseFromJson(json);
}

@JsonSerializable()
class OrderSummary {
  final int id;
  final DateTime? orderDate;
  final double totalAmount;
  final String status;
  final String? storeName;
  final int itemCount;

  OrderSummary({
    required this.id,
    this.orderDate,
    required this.totalAmount,
    required this.status,
    this.storeName,
    required this.itemCount,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);
}
