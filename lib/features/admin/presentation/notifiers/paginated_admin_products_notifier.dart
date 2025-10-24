import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/admin/admin_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

/// Notifier for paginated admin products (all products across all stores)
class PaginatedAdminProductsNotifier extends PaginatedNotifier<Product> {
  @override
  Future<PaginatedResponse<Product>> fetchPage(PaginationParams params) async {
    final repository = ref.read(adminRepositoryProvider);
    return repository.getAllProductsPaginated(pagination: params);
  }
}

/// Provider for paginated admin products
final paginatedAdminProductsProvider =
    NotifierProvider<PaginatedAdminProductsNotifier, PaginatedState<Product>>(
      PaginatedAdminProductsNotifier.new,
    );
