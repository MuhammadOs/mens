import 'package:json_annotation/json_annotation.dart';

part 'create_order_model.g.dart';

/// Request model for creating a new order
@JsonSerializable()
class CreateOrderRequest {
  final int storeId;
  final List<OrderItemRequest> items;
  final String paymentMethod;
  final String shippingAddress;
  final String? notes;

  CreateOrderRequest({
    required this.storeId,
    required this.items,
    required this.paymentMethod,
    required this.shippingAddress,
    this.notes,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

/// Individual order item in the request
@JsonSerializable()
class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemRequestToJson(this);
}

/// Response model for order creation
@JsonSerializable()
class CreateOrderResponse {
  final int orderId;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final String createdAt;

  CreateOrderResponse({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: _parseInt(json['orderId']) ?? 0,
      orderNumber: json['orderNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'orderNumber': orderNumber,
    'status': status,
    'totalAmount': totalAmount,
    'createdAt': createdAt,
  };
}

// Helper parsers to handle numbers returned as strings
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? (double.tryParse(value)?.toInt());
  }
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
