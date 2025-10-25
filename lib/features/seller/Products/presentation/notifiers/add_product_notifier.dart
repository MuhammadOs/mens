import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/core/services/image_upload_service.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product_image.dart';

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
    int primaryImageIndex = 0,
  }) async {
    state = const AsyncValue.loading(); // Set loading state
    try {
      // Step 1: Upload all images first
      final imageUploadService = ref.read(imageUploadServiceProvider);
      final List<ProductImage> productImages = [];

      for (int i = 0; i < images.length; i++) {
        try {
          final imageUrl = await imageUploadService.uploadImage(images[i]);
          productImages.add(
            ProductImage(
              imageUrl: imageUrl,
              altText: name, // Use product name as alt text
              isPrimary: i == primaryImageIndex,
            ),
          );
        } catch (e) {
          // Generic error for production
          throw Exception('Failed to upload image');
        }
      }

      // Step 2: Submit product with image URLs
      final repository = ref.read(productRepositoryProvider);
      try {
        await repository.addProduct(
          name: name,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          subCategoryId: subCategoryId,
          images: productImages,
        );
      } catch (e) {
        // Generic error for production
        throw Exception('Failed to create product');
      }

      state = const AsyncValue.data(null); // Set success state (back to idle)

      // Note: Provider invalidation is handled in the UI after navigation
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Set error state
      rethrow; // Re-throw to allow UI to handle
    }
  }
}
