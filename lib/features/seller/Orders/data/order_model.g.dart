// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => SellerOrderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'orders': instance.orders,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };

SellerOrderSummary _$SellerOrderSummaryFromJson(Map<String, dynamic> json) =>
    SellerOrderSummary(
      id: (json['id'] as num).toInt(),
      orderDate: json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      storeName: json['storeName'] as String?,
      itemCount: (json['itemCount'] as num).toInt(),
    );

Map<String, dynamic> _$SellerOrderSummaryToJson(SellerOrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderDate': instance.orderDate?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'storeName': instance.storeName,
      'itemCount': instance.itemCount,
    };

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  orderNumber: json['orderNumber'] as String,
  userId: (json['userId'] as num).toInt(),
  storeId: (json['storeId'] as num).toInt(),
  storeName: json['storeName'] as String,
  customerName: json['customerName'] as String,
  customerEmail: json['customerEmail'] as String?,
  customerPhone: json['customerPhone'] as String?,
  status: json['status'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  paymentMethod: json['paymentMethod'] as String?,
  notes: json['notes'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  shippingAddress: json['shippingAddress'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'userId': instance.userId,
  'storeId': instance.storeId,
  'storeName': instance.storeName,
  'customerName': instance.customerName,
  'customerEmail': instance.customerEmail,
  'customerPhone': instance.customerPhone,
  'status': instance.status,
  'totalAmount': instance.totalAmount,
  'paymentMethod': instance.paymentMethod,
  'notes': instance.notes,
  'items': instance.items,
  'shippingAddress': instance.shippingAddress,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  productImage: json['productImage'] as String,
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'productName': instance.productName,
  'productImage': instance.productImage,
  'quantity': instance.quantity,
  'price': instance.price,
  'subtotal': instance.subtotal,
};
