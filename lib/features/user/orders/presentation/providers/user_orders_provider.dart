import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/user/orders/data/order_repository.dart';
import 'package:mens/features/user/orders/domain/order_models.dart';

final userOrdersProvider = FutureProvider.autoDispose<List<OrderResponse>>((
  ref,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders();
});
