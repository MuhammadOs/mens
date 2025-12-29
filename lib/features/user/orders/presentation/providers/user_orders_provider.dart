import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/user/orders/data/order_repository.dart';
import 'package:mens/features/user/orders/domain/order_models.dart';

final userOrdersProvider = FutureProvider.autoDispose<List<OrderSummary>>((
  ref,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders();
});

final orderDetailsProvider = FutureProvider.autoDispose.family<OrderResponse, int>((
  ref,
  orderId,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrder(orderId);
});
