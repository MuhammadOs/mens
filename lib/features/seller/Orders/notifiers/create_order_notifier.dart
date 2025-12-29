import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/Orders/data/create_order_model.dart';
import 'package:dio/dio.dart';

/// Notifier for creating a new order
final createOrderProvider =
    FutureProvider.family<CreateOrderResponse, CreateOrderRequest>((
      ref,
      request,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      try {
        final response = await apiService.post(
          '/orders',
          data: request.toJson(),
        );

        // Handle the response data
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          return CreateOrderResponse.fromJson(data);
        }

        throw Exception('Invalid response format from order creation');
      } on DioException catch (e) {
        print('DioException creating order: ${e.message}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        rethrow;
      } catch (e) {
        print('Error creating order: $e');
        rethrow;
      }
    });
