import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/user/admin_repository.dart';
import 'package:mens/features/user/brands/domain/brand.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

/// Notifier for paginated brands/stores
class PaginatedBrandsNotifier extends PaginatedNotifier<Brand> {
  int? _categoryId;

  void setFilters({int? categoryId}) {
    _categoryId = categoryId;
    // Clear current items and reload
    state = PaginatedState<Brand>.initial();
    loadFirstPage();
  }

  @override
  Future<PaginatedResponse<Brand>> fetchPage(PaginationParams params) async {
    final repository = ref.read(adminRepositoryProvider);
    return repository.getAllBrandsPaginated(
      pagination: params,
      categoryId: _categoryId?.toString(),
    );
  }
}

/// Provider for paginated brands
final paginatedBrandsProvider =
    NotifierProvider<PaginatedBrandsNotifier, PaginatedState<Brand>>(
      PaginatedBrandsNotifier.new,
    );
