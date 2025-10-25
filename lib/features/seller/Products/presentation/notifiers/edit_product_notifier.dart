import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/core/services/image_upload_service.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product_image.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/paginated_products_notifier.dart';

/// State for the Edit Product operations.
/// AsyncValue<void> indicates idle (data(null)), loading, or error.
typedef EditProductOperationState = AsyncValue<void>;

/// Provider for the EditProductNotifier.
/// This provider is watched by the UI to see if a save operation is in progress.
final editProductNotifierProvider =
    NotifierProvider<EditProductNotifier, EditProductOperationState>(
      EditProductNotifier.new,
    );

/// Notifier responsible for triggering product updates.
class EditProductNotifier extends Notifier<EditProductOperationState> {
  /// Initial state is idle (data(null)).
  @override
  EditProductOperationState build() {
    return const AsyncValue.data(null);
  }

  /// Updates the product with new details and images.
  /// Handles both new images (XFile) and existing images (with id).
  Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<dynamic>
    images, // Mix of XFile (new) and ProductImage (existing)
    required int primaryImageIndex,
  }) async {
    // Set state to loading before the API call.
    state = const AsyncValue.loading();

    print("=== EDIT NOTIFIER: UPDATE PRODUCT ===");
    print("Product ID: $productId");
    print("Name: $name");
    print("Primary image index: $primaryImageIndex");
    print("Total images: ${images.length}");

    try {
      final imageUploadService = ref.read(imageUploadServiceProvider);
      final List<ProductImage> productImages = [];

      // Process images: upload new ones, keep existing ones
      for (int i = 0; i < images.length; i++) {
        final image = images[i];

        if (image is XFile) {
          // New image - upload it first
          print("Uploading new image: ${image.name}");
          try {
            final imageUrl = await imageUploadService.uploadImage(image);
            final isPrimary = i == primaryImageIndex;
            print("New image at index $i, isPrimary: $isPrimary");
            productImages.add(
              ProductImage(
                imageUrl: imageUrl,
                altText: name,
                isPrimary: isPrimary,
              ),
            );
          } catch (e) {
            throw Exception('Failed to upload image');
          }
        } else if (image is ProductImage) {
          // Existing image - reset isPrimary flag based on current index
          final isPrimary = i == primaryImageIndex;
          print(
            "Keeping existing image at index $i: ${image.imageUrl}, id: ${image.id}, isPrimary: $isPrimary",
          );
          productImages.add(
            ProductImage(
              id: image.id,
              imageUrl: image.imageUrl,
              altText: image.altText ?? name,
              isPrimary: isPrimary,
            ),
          );
        } else if (image is String) {
          // Legacy support: if it's just a URL string
          final isPrimary = i == primaryImageIndex;
          print(
            "Converting URL string to ProductImage at index $i: $image, isPrimary: $isPrimary",
          );
          productImages.add(
            ProductImage(imageUrl: image, altText: name, isPrimary: isPrimary),
          );
        }
      }

      print("=== IMAGES TO SEND ===");
      for (int i = 0; i < productImages.length; i++) {
        final img = productImages[i];
        print(
          "Image $i: id=${img.id}, isPrimary=${img.isPrimary}, url=${img.imageUrl}",
        );
      }

      // Update product via repository
      final repository = ref.read(productRepositoryProvider);
      try {
        await repository.updateProduct(
          productId: productId,
          name: name,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          subCategoryId: subCategoryId,
          images: productImages,
        );
      } catch (e) {
        throw Exception('Failed to update product');
      }

      print("✅ Product update successful in notifier.");

      // If successful, set state back to idle (data(null)).
      state = const AsyncValue.data(null);

      // Invalidate providers to trigger UI refresh elsewhere
      ref.invalidate(productsProvider);
      ref.read(paginatedProductsProvider.notifier).refresh();
      ref.read(paginatedAdminProductsProvider.notifier).refresh();

      // Refresh the specific product details
      ref.invalidate(productByIdProvider(productId));
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
}
