import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

// ... (ProductFilters class is unchanged) ...
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

  /// Call this from the screen to set the base category.
  void setMainCategory(int categoryId) {
    if (_currentFilters.categoryId != categoryId) {
      _currentFilters = _currentFilters.copyWith(categoryId: categoryId);
    }
  }

  @override
  Future<PaginatedResponse<Product>> fetchPage(PaginationParams params) async {
    final repository = ref.read(productRepositoryProvider);

    // GUARD CLAUSE: Don't fetch if the main category is missing.
    if (_currentFilters.categoryId == null) {
      
      // ✅ THE CORRECT FIX: Use the constructor from your file.
      return PaginatedResponse<Product>(
        items: [],
        page: params.page,       // The page that was requested
        pageSize: params.pageSize, // The page size that was requested
        totalCount: 0,             // 0 items found
        totalPages: 1,             // An empty result still counts as 1 page
      );
    }

    return repository.getProductsPaginated(
      pagination: params,
      categoryId: _currentFilters.categoryId,
      subCategoryId: _currentFilters.subCategoryId,
    );
  }

  /// Load products with new filters
  Future<void> loadWithFilters(ProductFilters filters) async {
    // ✅ THE FIX IS HERE
    // Don't use copyWith for subCategoryId, as it will ignore null.
    // Manually construct the new state to ensure null is applied.
    _currentFilters = ProductFilters(
      categoryId: _currentFilters.categoryId, // Preserve the main category
      subCategoryId: filters.subCategoryId,    // Apply the new subCategory (even if null)
    );

    await loadFirstPage();
  }

  /// Load products for a specific subcategory
  Future<void> loadBySubCategory(int? subCategoryId) async {
    await loadWithFilters(ProductFilters(subCategoryId: subCategoryId));
  }

  /// Load all products (for the main category)
  Future<void> loadAll() async {
    // This now correctly passes ProductFilters(subCategoryId: null)
    // to loadWithFilters, which will apply the null.
    await loadWithFilters(const ProductFilters());
  }
}

/// Provider for paginated products
final paginatedProductsProvider =
    NotifierProvider<PaginatedProductsNotifier, PaginatedState<Product>>(
  PaginatedProductsNotifier.new,
);