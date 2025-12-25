import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/user/orders/domain/order_models.dart';

abstract class OrderRepository {
  Future<OrderResponse> createOrder(OrderRequest request);
  Future<List<OrderResponse>> getOrders();
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return OrderRepositoryImpl(dio);
});

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;
  OrderRepositoryImpl(this._dio);

  @override
  Future<OrderResponse> createOrder(OrderRequest request) async {
    try {
      final response = await _dio.post('/orders', data: request.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderResponse.fromJson(response.data);
      }
      throw Exception('Failed to create order');
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        // Attempt to read error message
        final msg = e.response!.data['message'] ?? e.message;
        throw Exception(msg);
      }
      throw Exception('Network error creating order: ${e.message}');
    }
  }

  @override
  Future<List<OrderResponse>> getOrders() async {
    try {
      final response = await _dio.get('/orders');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => OrderResponse.fromJson(e))
              .toList();
        } else if (response.data is Map<String, dynamic> &&
            response.data['items'] is List) {
          return (response.data['items'] as List)
              .map((e) => OrderResponse.fromJson(e))
              .toList();
        }
      }
      throw Exception('Failed to fetch orders');
    } on DioException catch (e) {
      throw Exception('Network error fetching orders: ${e.message}');
    }
  }
}
