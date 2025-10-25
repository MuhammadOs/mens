import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Required for XFile
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product_image.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/edit_product_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/widgets/custom_dropdown.dart';
import 'package:mens/shared/widgets/custom_text_field.dart'; // Adjust path if needed
import 'package:skeletonizer/skeletonizer.dart'; // Import Skeletonizer

// ignore_for_file: unused_import

class EditProductScreen extends HookConsumerWidget {
  final int productId; // Product ID passed via router
  const EditProductScreen({required this.productId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Providers and State ---
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    // 1. Fetch initial product data using the ID-specific provider
    final productAsyncValue = ref.watch(productByIdProvider(productId));

    // 2. Watch the separate notifier for the *status* of update operations
    final editOperationState = ref.watch(editProductNotifierProvider);
    // 3. Read the notifier to trigger update actions
    final editNotifier = ref.read(editProductNotifierProvider.notifier);

    // --- Controllers ---
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final priceController = useTextEditingController();
    final stockController = useTextEditingController();
    // State hook for the selected subcategory ID
    final selectedSubCategoryId = useState<int?>(null);

    // --- Image State ---
    final images = useState<List<dynamic>>(
      [],
    ); // Mix of existing URLs (String) and new files (XFile)
    final imagePicker = useMemoized(() => ImagePicker());
    final primaryImageIndex = useState<int>(
      0,
    ); // Track which image is marked as primary

    // --- Functions ---
    Future<void> pickImages() async {
      final List<XFile> pickedFiles = await imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final currentPaths = images.value
            .whereType<XFile>()
            .map((f) => f.path)
            .toSet();
        final newUniqueFiles = pickedFiles
            .where((f) => !currentPaths.contains(f.path))
            .toList();
        images.value = [...images.value, ...newUniqueFiles];
      }
    }

    void removeImage(int index) {
      final newList = List.from(images.value)..removeAt(index);
      images.value = newList;
      if (primaryImageIndex.value >= images.value.length) {
        primaryImageIndex.value = 0;
      }
    }

    void setPrimaryImage(int index) {
      primaryImageIndex.value = index;
    }

    // --- State Listener for Operation Status ---
    ref.listen(editProductNotifierProvider, (previous, next) {
      final bool wasLoading =
          previous is AsyncLoading; // Check if previous state was loading

      if (wasLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product updated!"),
            backgroundColor: Colors.green,
          ), // TODO: Localize
        );
      } else if (wasLoading && next is AsyncError) {
        // Show generic error message for production
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUpdatingProduct),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });

    // --- Build Method ---
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"), // TODO: Localize
        actions: [
          // Show loading indicator based on the OPERATION state
          editOperationState.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    // --- SAVE LOGIC ---
                    final currentProductData = productAsyncValue.value;
                    if (currentProductData == null) {
                      return; // Don't save if initial data isn't loaded
                    }

                    // TODO: Add form validation

                    print("=== STARTING PRODUCT UPDATE ===");
                    print("Product ID: $productId");
                    print("Images: ${images.value.length}");
                    print("Primary image index: ${primaryImageIndex.value}");

                    try {
                      // Call the unified update method
                      await editNotifier.updateProduct(
                        productId: productId,
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        stockQuantity: int.tryParse(stockController.text) ?? 0,
                        subCategoryId:
                            selectedSubCategoryId.value ??
                            currentProductData.subCategoryId,
                        images: images.value,
                        primaryImageIndex: primaryImageIndex.value,
                      );

                      print("✅ Product update successful!");

                      if (context.mounted) {
                        context.pop();
                      }
                    } catch (e) {
                      print("❌ Error updating product: $e");
                      // Error handling is done by the listener
                    }
                  },
                ),
        ],
      ),
      // Use AsyncValue.when for the INITIAL PRODUCT data loading
      body: productAsyncValue.when(
        skipLoadingOnRefresh: false,
        data: (product) {
          // --- Pre-fill controllers and image state using useEffect ---
          useEffect(() {
            nameController.text = product.name;
            descriptionController.text = product.description;
            priceController.text = product.price.toStringAsFixed(2);
            stockController.text = product.stockQuantity.toString();

            // Only set subcategory from product data if user hasn't changed it
            if (selectedSubCategoryId.value == null) {
              selectedSubCategoryId.value = product.subCategoryId;
            }

            // Only set images from product data on the very first load
            if (images.value.isEmpty && product.images.isNotEmpty) {
              images.value = List<dynamic>.from(product.images);
              // Find the primary image index
              final primaryIndex = product.images.indexWhere(
                (img) => img.isPrimary,
              );
              primaryImageIndex.value = primaryIndex >= 0 ? primaryIndex : 0;
            }
            return null;
          }, [product]); // Re-run if the 'product' object changes

          // --- UI ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Form Fields ---
                  CustomTextField(
                    labelText: l10n.productName,
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  Consumer(
                    builder: (context, ref, _) {
                      final subCategoriesAsync = ref.watch(
                        subCategoriesProvider(product.categoryId),
                      );
                      return subCategoriesAsync.when(
                        data: (subCats) {
                          final dropdownItems = subCats
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList();

                          // Use the state hook value for the dropdown
                          final isValidValue = subCats.any(
                            (cat) => cat.id == selectedSubCategoryId.value,
                          );
                          final dropdownValue = isValidValue
                              ? selectedSubCategoryId.value
                              : null;

                          return CustomDropdownField<int>(
                            key: ValueKey(
                              'subcategory_edit_${dropdownValue ?? 'null'}',
                            ),
                            labelText: l10n.category,
                            hintText: l10n.categoryHint,
                            value: dropdownValue,
                            items: dropdownItems,
                            onChanged: (int? newValue) =>
                                selectedSubCategoryId.value = newValue,
                            validator: (value) =>
                                value == null ? l10n.validationRequired : null,
                          );
                        },
                        loading: () => Skeletonizer(
                          // Skeleton for Dropdown
                          enabled: true,
                          child: CustomDropdownField<int>(
                            labelText: l10n.categoryLabel,
                            hintText: l10n.categoryHint,
                            value: null,
                            items: const [],
                            onChanged: (v) {},
                          ),
                        ),
                        error: (e, s) => Padding(
                          // Error Display
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            l10n.errorLoadingCategories,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.description,
                    controller: descriptionController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          labelText: l10n.price,
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          labelText: l10n.stock,
                          controller: stockController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Image Upload Section ---
                  Text(l10n.productImage, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.value.length + 1, // +1 for add button
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        // Add Button
                        if (index == images.value.length) {
                          return InkWell(
                            onTap: pickImages,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.5),
                                ),
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                color: theme.colorScheme.primary,
                                size: 30,
                              ),
                            ),
                          );
                        }

                        // Image Tile
                        final item = images.value[index];
                        final bool isPrimary = index == primaryImageIndex.value;

                        // Extract image source (URL or file path)
                        String? imageUrl;
                        String? imagePath;

                        if (item is XFile) {
                          imagePath = item.path;
                        } else if (item is ProductImage) {
                          imageUrl = item.imageUrl;
                        } else if (item is String) {
                          imageUrl = item;
                        }

                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            GestureDetector(
                              // Allow tapping to set primary
                              onTap: () => setPrimaryImage(index),
                              child: Container(
                                width: 100,
                                height: 100,
                                padding: const EdgeInsets.all(
                                  2,
                                ), // Padding to show border inside
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    // Highlight primary
                                    color: isPrimary
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    9,
                                  ), // Inner radius smaller than container
                                  child: imagePath != null
                                      ? Image.file(
                                          File(imagePath),
                                          width: 94,
                                          height: 94,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          imageUrl ?? '',
                                          width: 94,
                                          height: 94,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 94,
                                            height: 94,
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            // Remove button
                            InkWell(
                              onTap: () => removeImage(index),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap an image to set it as primary", // TODO: Localize
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        // --- Loading State ---
        loading: () => Skeletonizer(
          // Show skeleton during initial product load
          enabled: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(width: 120),
                  const SizedBox(height: 8),
                  Bone(height: 50, borderRadius: BorderRadius.circular(12)),
                  const SizedBox(height: 16),
                  Bone.text(width: 100),
                  const SizedBox(height: 8),
                  Bone(height: 50, borderRadius: BorderRadius.circular(12)),
                  const SizedBox(height: 16),
                  Bone.text(width: 100),
                  const SizedBox(height: 8),
                  Bone(height: 100, borderRadius: BorderRadius.circular(12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.text(width: 50),
                            const SizedBox(height: 8),
                            Bone(
                              height: 50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.text(width: 50),
                            const SizedBox(height: 8),
                            Bone(
                              height: 50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Bone.text(width: 150),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Bone(
                            width: 100,
                            height: 100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // --- Error State ---
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.errorLoadingProduct,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
