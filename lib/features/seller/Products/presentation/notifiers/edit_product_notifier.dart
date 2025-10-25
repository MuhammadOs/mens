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

  /// Updates the product's images using separate endpoints for primary and other images.
  Future<void> updateImages({
    required int productId,
    required XFile? primaryImage, // Can be null if not changed
    required List<XFile> otherNewImages,
    required List<String> existingOtherImageUrls,
    required bool isPrimaryNew, // True if primaryImage is a new upload
  }) async {
    // Set state to loading.
    state = const AsyncValue.loading();

    print("=== EDIT NOTIFIER: UPDATE IMAGES ===");
    print("Product ID: $productId");
    print(
      "Primary image: ${isPrimaryNew ? 'NEW (${primaryImage?.name})' : 'EXISTING'}",
    );
    print("Other new images count: ${otherNewImages.length}");
    print("Existing other URLs count: ${existingOtherImageUrls.length}");

    try {
      final repository = ref.read(productRepositoryProvider);

      // 1. Update primary image if it's new
      if (isPrimaryNew && primaryImage != null) {
        print("Uploading new primary image...");
        await repository.updatePrimaryImage(
          productId: productId,
          primaryImage: primaryImage,
        );
        print("✅ Primary image uploaded successfully!");
      } else {
        print("Primary image not changed, skipping upload.");
      }

      // 2. Update other images (new + existing URLs)
      if (otherNewImages.isNotEmpty || existingOtherImageUrls.isNotEmpty) {
        print("Updating other images...");
        await repository.updateOtherImages(
          productId: productId,
          newImages: otherNewImages,
          existingImageUrls: existingOtherImageUrls,
        );
        print("✅ Other images updated successfully!");
      } else {
        print("No other images to update.");
      }

      // If successful, set state back to idle.
      state = const AsyncValue.data(null);
      print("✅ Product images update successful in notifier.");

      // Invalidate providers to refetch data with new images
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
