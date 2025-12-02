import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/user/user_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';

class PaginatedBrandProductsNotifier extends PaginatedNotifier<Product> {
  final int brandId;
  
  PaginatedBrandProductsNotifier(this.brandId);

  @override
  Future<PaginatedResponse<Product>> fetchPage(PaginationParams params) async {
    final repository = ref.read(adminRepositoryProvider);
    return repository.getProductsByBrandPaginated(
      brandId: brandId,
      pagination: params,
    );
  }
}

// Family provider to cache state per brand ID
final brandProductsProvider = NotifierProvider.family.autoDispose<
    PaginatedBrandProductsNotifier, PaginatedState<Product>, int>(
  PaginatedBrandProductsNotifier.new,
);