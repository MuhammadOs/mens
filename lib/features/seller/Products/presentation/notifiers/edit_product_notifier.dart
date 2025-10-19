import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';

/// State for the Edit Product *operations* (update details, update images).
/// AsyncValue<void> indicates idle (data(null)), loading, or error.
typedef EditProductOperationState = AsyncValue<void>;

/// Provider for the EditProductNotifier.
/// This provider is watched by the UI to see if a save operation is in progress.
final editProductNotifierProvider =
    NotifierProvider<EditProductNotifier, EditProductOperationState>(
  EditProductNotifier.new,
);

/// Notifier responsible for triggering product updates (details and images).
class EditProductNotifier extends Notifier<EditProductOperationState> {
  /// Initial state is idle (data(null)).
  @override
  EditProductOperationState build() {
    return const AsyncValue.data(null);
  }

  /// Updates the product's text details via the API.
  Future<void> updateDetails({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
  }) async {
    // Set state to loading before the API call.
    state = const AsyncValue.loading();
    try {
      // Access the repository using ref.read inside the method.
      final repository = ref.read(productRepositoryProvider);
      
      // Await the API call
      await repository.updateProductDetails(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        subCategoryId: subCategoryId,
      );
      
      // If successful, set state back to idle (data(null)).
      state = const AsyncValue.data(null);
      print("Product details update successful.");

      // Invalidate providers to trigger UI refresh elsewhere
      ref.invalidate(productsProvider); // Refreshes the main product list
      ref.invalidate(productByIdProvider(productId)); // Refreshes the details on this screen
    } catch (e, st) {
      // If an error occurs, set the state to error.
      print("Error updating product details: $e");
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates the product's images via the API.
  Future<void> updateImages({
    required int productId,
    required List<XFile> images,
    int primaryImageIndex = 0,
  }) async {
    // Set state to loading.
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(productRepositoryProvider);
      
      // Call the repository method.
      await repository.updateProductImages(
        productId: productId,
        images: images,
        primaryImageIndex: primaryImageIndex,
      );

      // If successful, set state back to idle.
      state = const AsyncValue.data(null);
      print("Product images update successful.");

      // Invalidate providers to refetch data with new images
      ref.invalidate(productsProvider);
      ref.invalidate(productByIdProvider(productId));
    } catch (e, st) {
      // Set error state.
      print("Error updating product images: $e");
      state = AsyncValue.error(e, st);
    }
  }
}