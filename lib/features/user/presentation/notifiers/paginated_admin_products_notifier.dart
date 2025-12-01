import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/user/admin_repository.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

/// Notifier for paginated admin products (all products across all stores)
class PaginatedAdminProductsNotifier extends PaginatedNotifier<Product> {
  int? _categoryId;
  int? _subCategoryId;

  void setFilters({int? categoryId, int? subCategoryId}) {
    _categoryId = categoryId;
    _subCategoryId = subCategoryId;
    loadFirstPage();
  }

  @override
  Future<PaginatedResponse<Product>> fetchPage(PaginationParams params) async {
    final repository = ref.read(adminRepositoryProvider);
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final storeId = userProfile?.store?.id.toString();

    return repository.getAllProductsPaginated(
      pagination: params,
      categoryId: _categoryId?.toString(),
      subCategoryId: _subCategoryId?.toString(),
      storeId: storeId,
    );
  }
}

/// Provider for paginated admin products
final paginatedAdminProductsProvider =
    NotifierProvider<PaginatedAdminProductsNotifier, PaginatedState<Product>>(
      PaginatedAdminProductsNotifier.new,
    );
