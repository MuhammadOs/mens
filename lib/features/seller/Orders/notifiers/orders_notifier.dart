import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/Orders/data/order_model.dart';
import 'package:dio/dio.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

// Keeping ordersProvider as it might be used elsewhere, but ideally we deprecate it.
final ordersProvider =
    FutureProvider.family<
      OrderResponse,
      ({int page, int pageSize, String? status})
    >((ref, params) async {
      final apiService = ref.watch(apiServiceProvider);
      try {
        final queryParams = <String, dynamic>{
          'page': params.page,
          'pageSize': params.pageSize,
        };
        if (params.status != null && params.status!.isNotEmpty) {
          queryParams['status'] = params.status;
        }

        final response = await apiService.get(
          '/orders/store',
          queryParameters: queryParams,
        );

        if (response.data is Map<String, dynamic>) {
          return OrderResponse.fromJson(response.data as Map<String, dynamic>);
        }
        throw Exception('Invalid response format');
      } on DioException catch (e) {
        rethrow;
      } catch (e) {
        rethrow;
      }
    });

final updateOrderStatusProvider =
    FutureProvider.family<void, (int orderId, String status)>((
      ref,
      params,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      try {
        await apiService.patch(
          '/orders/${params.$1}/status',
          data: {'status': params.$2},
        );
        ref.invalidate(sellerOrderDetailsProvider(params.$1));
        ref.invalidate(paginatedOrdersProvider);
        ref.invalidate(ordersProvider); 
      } catch (e) {
        rethrow;
      }
    });

final sellerOrderDetailsProvider = FutureProvider.family<Order, int>((
  ref,
  orderId,
) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/orders/$orderId');
    if (response.data is Map<String, dynamic>) {
      return Order.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Invalid response format');
  } on DioException catch (e) {
    rethrow;
  }
});


/// Notifier for paginated orders
class PaginatedOrdersNotifier extends PaginatedNotifier<SellerOrderSummary> {
  String? _status;

  /// Update the status filter and reload
  Future<void> setStatusFilter(String? status) async {
    if (_status != status) {
      _status = status;
      await loadFirstPage();
    }
  }

  @override
  Future<PaginatedResponse<SellerOrderSummary>> fetchPage(PaginationParams params) async {
    final apiService = ref.read(apiServiceProvider);
    final queryParams = <String, dynamic>{
      'page': params.page,
      'pageSize': params.pageSize,
    };
    
    // Only add status if it's set and not "All" (assuming UI might pass "All")
    if (_status != null && _status != 'All') {
      queryParams['status'] = _status;
    }

    try {
      final response = await apiService.get(
        '/orders/store',
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        final orderResponse = OrderResponse.fromJson(response.data as Map<String, dynamic>);
        return PaginatedResponse<SellerOrderSummary>(
          items: orderResponse.orders,
          totalCount: orderResponse.totalCount,
          page: orderResponse.page,
          pageSize: orderResponse.pageSize,
          totalPages: orderResponse.totalPages,
        );
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
}

final paginatedOrdersProvider = 
    NotifierProvider<PaginatedOrdersNotifier, PaginatedState<SellerOrderSummary>>(
  PaginatedOrdersNotifier.new,
);
