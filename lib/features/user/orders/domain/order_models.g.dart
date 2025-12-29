// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderRequest _$OrderRequestFromJson(Map<String, dynamic> json) => OrderRequest(
  storeId: (json['storeId'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  paymentMethod: json['paymentMethod'] as String,
  addressId: (json['addressId'] as num?)?.toInt(),
  shippingAddress: json['shippingAddress'] as String,
  notes: json['notes'] as String,
);

Map<String, dynamic> _$OrderRequestToJson(OrderRequest instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'paymentMethod': instance.paymentMethod,
      'addressId': instance.addressId,
      'shippingAddress': instance.shippingAddress,
      'notes': instance.notes,
    };

OrderItemRequest _$OrderItemRequestFromJson(Map<String, dynamic> json) =>
    OrderItemRequest(
      productId: (json['productId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$OrderItemRequestToJson(OrderItemRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
    };

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      customerName: json['customerName'] as String?,
      storeId: (json['storeId'] as num?)?.toInt() ?? 0,
      storeName: json['storeName'] as String?,
      orderDate: json['orderDate'] == null
          ? null
          : DateTime.parse(json['orderDate'] as String),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Unknown',
      paymentMethod: json['paymentMethod'] as String? ?? 'Unknown',
      addressId: (json['addressId'] as num?)?.toInt() ?? 0,
      address: json['address'] == null
          ? null
          : OrderAddress.fromJson(json['address'] as Map<String, dynamic>),
      shippingAddress: json['shippingAddress'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'customerName': instance.customerName,
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'orderDate': instance.orderDate?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'addressId': instance.addressId,
      'address': instance.address,
      'shippingAddress': instance.shippingAddress,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'items': instance.items,
    };

OrderAddress _$OrderAddressFromJson(Map<String, dynamic> json) => OrderAddress(
  id: (json['id'] as num).toInt(),
  city: json['city'] as String? ?? '',
  street: json['street'] as String? ?? '',
  buildingNo: json['buildingNo'] as String? ?? '',
  floorNo: json['floorNo'] as String? ?? '',
  flatNo: json['flatNo'] as String? ?? '',
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$OrderAddressToJson(OrderAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'city': instance.city,
      'street': instance.street,
      'buildingNo': instance.buildingNo,
      'floorNo': instance.floorNo,
      'flatNo': instance.flatNo,
      'notes': instance.notes,
    };

OrderItemResponse _$OrderItemResponseFromJson(Map<String, dynamic> json) =>
    OrderItemResponse(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? 'Unknown Product',
      productImage: json['productImage'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$OrderItemResponseToJson(OrderItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'subtotal': instance.subtotal,
    };

OrderSummary _$OrderSummaryFromJson(Map<String, dynamic> json) => OrderSummary(
  id: (json['id'] as num).toInt(),
  orderDate: json['orderDate'] == null
      ? null
      : DateTime.parse(json['orderDate'] as String),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  status: json['status'] as String,
  storeName: json['storeName'] as String?,
  itemCount: (json['itemCount'] as num).toInt(),
);

Map<String, dynamic> _$OrderSummaryToJson(OrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderDate': instance.orderDate?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'storeName': instance.storeName,
      'itemCount': instance.itemCount,
    };
