import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/paginated_products_notifier.dart';

// State for the Add Product process
typedef AddProductState = AsyncValue<void>;

// Provider for the notifier
final addProductNotifierProvider =
    NotifierProvider<AddProductNotifier, AddProductState>(
      AddProductNotifier.new,
    );

class AddProductNotifier extends Notifier<AddProductState> {
  @override
  AddProductState build() {
    return const AsyncValue.data(null); // Initial idle state
  }

  Future<void> submitProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<XFile> images,
  }) async {
    state = const AsyncValue.loading(); // Set loading state
    try {
      final repository = ref.read(productRepositoryProvider);
      await repository.addProduct(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        subCategoryId: subCategoryId,
        images: images,
      );
      state = const AsyncValue.data(null); // Set success state (back to idle)

      // Invalidate providers to trigger UI refresh
      ref.invalidate(productsProvider); // Refreshes the main product list
      ref.invalidate(
        paginatedProductsProvider,
      ); // Refreshes paginated product list
      ref.invalidate(
        paginatedAdminProductsProvider,
      ); // Refreshes admin paginated product list
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Set error state
    }
  }
}
