import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

/// Filter parameters for product queries
class ProductFilters {
  final int? categoryId;
  final int? subCategoryId;

  const ProductFilters({this.categoryId, this.subCategoryId});

  ProductFilters copyWith({int? categoryId, int? subCategoryId}) {
    return ProductFilters(
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilters &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          subCategoryId == other.subCategoryId;

  @override
  int get hashCode => categoryId.hashCode ^ subCategoryId.hashCode;
}

/// Notifier for paginated products
class PaginatedProductsNotifier extends PaginatedNotifier<Product> {
  ProductFilters _currentFilters = const ProductFilters();

  /// Get current filters
  ProductFilters get currentFilters => _currentFilters;

  @override
  Future<PaginatedResponse<Product>> fetchPage(PaginationParams params) async {
    final repository = ref.read(productRepositoryProvider);
    return repository.getProductsPaginated(
      pagination: params,
      categoryId: _currentFilters.categoryId,
      subCategoryId: _currentFilters.subCategoryId,
    );
  }

  /// Load products with new filters
  Future<void> loadWithFilters(ProductFilters filters) async {
    _currentFilters = filters;
    await loadFirstPage();
  }

  /// Load products for a specific subcategory
  Future<void> loadBySubCategory(int? subCategoryId) async {
    await loadWithFilters(ProductFilters(subCategoryId: subCategoryId));
  }

  /// Load all products (no filters)
  Future<void> loadAll() async {
    await loadWithFilters(const ProductFilters());
  }
}

/// Provider for paginated products
final paginatedProductsProvider =
    NotifierProvider<PaginatedProductsNotifier, PaginatedState<Product>>(
      PaginatedProductsNotifier.new,
    );
