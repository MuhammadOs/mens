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
    state = const AsyncValue.loading();
    try {
      // Step 1: Upload all images first
      final imageUploadService = ref.read(imageUploadServiceProvider);
      final List<ProductImage> productImages = [];

      for (int i = 0; i < images.length; i++) {
        // Let the real upload error propagate — the service provides the message
        final imageUrl = await imageUploadService.uploadImage(images[i]);
        productImages.add(
          ProductImage(
            imageUrl: imageUrl,
            altText: name,
            isPrimary: i == primaryImageIndex,
          ),
        );
      }

      // Step 2: Submit product with image URLs
      // Let the real API error propagate — the repository extracts the server message
      final repository = ref.read(productRepositoryProvider);
      await repository.addProduct(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        subCategoryId: subCategoryId,
        images: productImages,
      );

      state = const AsyncValue.data(null); // Success — back to idle
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Do NOT rethrow — error is surfaced via state, the UI listens to AsyncError
    }
  }
}
