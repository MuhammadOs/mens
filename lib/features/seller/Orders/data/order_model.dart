import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderResponse {
  final List<SellerOrderSummary> orders;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  OrderResponse({
    required this.orders,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final ordersList = <SellerOrderSummary>[];
    final rawOrders = json['items'] ?? json['data'] ?? json['orders'];
    if (rawOrders is List) {
      for (final item in rawOrders) {
        if (item is Map<String, dynamic>) {
          ordersList.add(SellerOrderSummary.fromJson(item));
        }
      }
    }

    return OrderResponse(
      orders: ordersList,
      totalCount: _parseInt(json['totalCount']) ?? 0,
      page: _parseInt(json['page']) ?? 1,
      pageSize: _parseInt(json['pageSize']) ?? 20,
      totalPages: _parseInt(json['totalPages']) ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'orders': orders.map((o) => o.toJson()).toList(),
        'totalCount': totalCount,
        'page': page,
        'pageSize': pageSize,
        'totalPages': totalPages,
      };
}

@JsonSerializable()
class SellerOrderSummary {
  final int id;
  final DateTime? orderDate;
  final double totalAmount;
  final String status;
  final String? storeName;
  final int itemCount;

  SellerOrderSummary({
    required this.id,
    this.orderDate,
    required this.totalAmount,
    required this.status,
    this.storeName,
    required this.itemCount,
  });

  factory SellerOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$SellerOrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SellerOrderSummaryToJson(this);
}

@JsonSerializable()
class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final int storeId;
  final String storeName;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String status;
  final double totalAmount;
  final String? paymentMethod;
  final String? notes;
  final List<OrderItem> items;
  final String shippingAddress;
  final String createdAt;
  final String updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.storeId,
    required this.storeName,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.status,
    required this.totalAmount,
    this.paymentMethod,
    this.notes,
    required this.items,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: _parseInt(json['id']) ?? 0,
      orderNumber: json['orderNumber']?.toString() ?? json['id']?.toString() ?? '',
      userId: _parseInt(json['userId']) ?? 0,
      storeId: _parseInt(json['storeId']) ?? 0,
      storeName: json['storeName']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? 'Guest',
      customerEmail: json['customerEmail']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString(),
      notes: json['notes']?.toString(),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => e is Map<String, dynamic>
                    ? OrderItem.fromJson(e)
                    : OrderItem.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      shippingAddress: json['shippingAddress']?.toString() ?? 'No address provided',
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'userId': userId,
    'storeId': storeId,
    'storeName': storeName,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerPhone': customerPhone,
    'status': status,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'notes': notes,
    'items': items.map((i) => i.toJson()).toList(),
    'shippingAddress': shippingAddress,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

@JsonSerializable()
class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _parseInt(json['id']) ?? 0,
      productId: _parseInt(json['productId']) ?? 0,
      productName: json['productName']?.toString() ?? '',
      productImage: json['productImage']?.toString() ?? '',
      quantity: _parseInt(json['quantity']) ?? 0,
      price: _parseDouble(json['unitPrice']) ?? _parseDouble(json['price']) ?? 0.0,
      subtotal: _parseDouble(json['subtotal']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'productImage': productImage,
    'quantity': quantity,
    'unitPrice': price,
    'subtotal': subtotal,
  };
}

// Enum for order statuses
enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  processing('Processing'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName => value;
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
