import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/paginated_products_notifier.dart';

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

    print("=== EDIT NOTIFIER: UPDATE DETAILS ===");
    print("Product ID: $productId");
    print("Name: $name");
    print(
      "Description: ${description.substring(0, description.length > 50 ? 50 : description.length)}...",
    );
    print("Price: $price");
    print("Stock: $stockQuantity");
    print("SubCategory ID: $subCategoryId");

    try {
      // Access the repository using ref.read inside the method.
      final repository = ref.read(productRepositoryProvider);

      print("Calling repository.updateProductDetails...");
      // Await the API call
      await repository.updateProductDetails(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        subCategoryId: subCategoryId,
      );

      print("Repository call successful!");

      // If successful, set state back to idle (data(null)).
      state = const AsyncValue.data(null);
      print("✅ Product details update successful in notifier.");

      // Invalidate providers to trigger UI refresh elsewhere
      // Note: We refresh the paginated providers to update the product in the list
      ref.read(paginatedProductsProvider.notifier).refresh();
      ref.read(paginatedAdminProductsProvider.notifier).refresh();

      // Refresh the specific product details
      ref.invalidate(
        productByIdProvider(productId),
      ); // Refreshes the details on this screen
    } catch (e, st) {
      // If an error occurs, set the state to error.
      print("=== ERROR IN NOTIFIER ===");
      print("Error type: ${e.runtimeType}");
      print("Error: $e");
      print("Stack trace: $st");
      state = AsyncValue.error(e, st);

      // Re-throw to allow UI to handle
      rethrow;
    }
  }

  /// Updates the product's images via the API.
  Future<void> updateImages({
    required int productId,
    required List<XFile> images,
    required List<String> existingImageUrls,
    int primaryImageIndex = 0,
  }) async {
    // Set state to loading.
    state = const AsyncValue.loading();

    print("=== EDIT NOTIFIER: UPDATE IMAGES ===");
    print("Product ID: $productId (type: ${productId.runtimeType})");
    print("New images count: ${images.length}");
    print("Existing URLs count: ${existingImageUrls.length}");
    print(
      "Primary index: $primaryImageIndex (type: ${primaryImageIndex.runtimeType})",
    );

    try {
      final repository = ref.read(productRepositoryProvider);

      print("Calling repository.updateProductImages...");
      // Call the repository method.
      final List<String> newUrls = await repository.updateProductImages(
        productId: productId,
        images: images,
        existingImageUrls: existingImageUrls,
        primaryImageIndex: primaryImageIndex,
      );

      print("Repository call successful! Returned ${newUrls.length} URLs");

      // If successful, set state back to idle.
      state = const AsyncValue.data(null);
      print("✅ Product images update successful in notifier.");

      // Invalidate providers to refetch data with new images
      // Note: We refresh the paginated providers to update the product in the list
      ref.read(paginatedProductsProvider.notifier).refresh();
      ref.read(paginatedAdminProductsProvider.notifier).refresh();

      // Refresh the specific product details
      ref.invalidate(productByIdProvider(productId));
    } catch (e, st) {
      // Set error state.
      print("=== ERROR IN NOTIFIER ===");
      print("Error type: ${e.runtimeType}");
      print("Error: $e");
      print("Stack trace: $st");
      state = AsyncValue.error(e, st);

      // Re-throw to allow UI to handle
      rethrow;
    }
  }
}
