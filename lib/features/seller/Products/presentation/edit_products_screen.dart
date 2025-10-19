import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Required for XFile
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/edit_product_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/widgets/custom_dropdown.dart';
import 'package:mens/shared/widgets/custom_text_field.dart'; // Adjust path if needed
import 'package:skeletonizer/skeletonizer.dart'; // Import Skeletonizer

class EditProductScreen extends HookConsumerWidget {
  final int productId; // Product ID passed via router
  const EditProductScreen({required this.productId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Providers and State ---
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    // Fetch initial product data using the ID-specific provider
    final productAsyncValue = ref.watch(productByIdProvider(productId));

    // Watch the separate notifier for the *status* of update operations
    final editOperationState = ref.watch(editProductNotifierProvider);
    // Read the notifier to trigger update actions
    final editNotifier = ref.read(editProductNotifierProvider.notifier);

    // --- Controllers ---
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final priceController = useTextEditingController();
    final stockController = useTextEditingController();
    // State hook for the selected subcategory ID (independent of initial load)
    final selectedSubCategoryId = useState<int?>(null);

    // --- Image State ---
    final images = useState<List<dynamic>>([]); // Mix of existing URLs (String) and new files (XFile)
    final imagePicker = useMemoized(() => ImagePicker());
    final primaryImageIndex = useState<int>(0); // Track which image is marked as primary

    // --- Functions ---
    // Pick new images and add them to the state list
    Future<void> pickImages() async {
      final List<XFile> pickedFiles = await imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        // Avoid adding duplicates if user picks the same file again
        final currentPaths = images.value.whereType<XFile>().map((f) => f.path).toSet();
        final newUniqueFiles = pickedFiles.where((f) => !currentPaths.contains(f.path)).toList();
        images.value = [...images.value, ...newUniqueFiles];
      }
    }

    // Remove an image (either URL or XFile) from the list
    void removeImage(int index) {
       final newList = List.from(images.value)..removeAt(index);
       images.value = newList;
       // Reset primary index if the removed image was primary or beyond the new list length
       if (primaryImageIndex.value >= images.value.length) {
          primaryImageIndex.value = 0;
       }
    }

    // Set the primary image index
    void setPrimaryImage(int index) {
        primaryImageIndex.value = index;
    }

    // --- State Listener for Operation Status ---
    // Show messages after update attempts
    ref.listen(editProductNotifierProvider, (previous, next) {
      final bool wasLoading = previous is AsyncLoading; // Check previous state safely

      if (wasLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product updated!"), backgroundColor: Colors.green), // TODO: Localize
        );
        // Optionally pop after successful save
        // if(context.mounted) context.pop();
      } else if (wasLoading && next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating: ${next.error}"), backgroundColor: Colors.red), // TODO: Localize
        );
      }
    });

    // --- Build Method ---
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"), // TODO: Localize
        actions: [
          // Show loading indicator or Save button based on the OPERATION state
          editOperationState.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    // --- SAVE LOGIC ---
                    // Get the currently loaded product data directly
                    final currentProductData = productAsyncValue.value;
                    if (currentProductData == null) return; // Don't save if initial data isn't loaded

                    // TODO: Add form validation using a Form widget + GlobalKey if needed

                    final List<XFile> newImagesToUpload = images.value.whereType<XFile>().toList();
                    final List<String> existingImageUrls = images.value.whereType<String>().toList();

                    // Determine if images section needs updating
                    final bool imagesChanged = newImagesToUpload.isNotEmpty ||
                         existingImageUrls.length != currentProductData.imageUrls.length ||
                         primaryImageIndex.value != 0; // Simplistic check, assumes 0 is default

                    bool detailsSuccess = true;
                    bool imagesSuccess = true;

                    // 1. Update Text Details using the editNotifier, passing productId
                    try {
                      await editNotifier.updateDetails(
                        productId: productId, // Pass the correct product ID
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        stockQuantity: int.tryParse(stockController.text) ?? 0,
                        subCategoryId: selectedSubCategoryId.value ?? currentProductData.subCategoryId,
                      );
                    } catch (e) {
                      detailsSuccess = false;
                      print("Error during updateDetails call: $e");
                      // Error is handled by the listener, no need to show SnackBar here
                    }

                    // 2. Update Images if details update succeeded and images changed
                    if (detailsSuccess && imagesChanged) {
                       // Only send new files if your API replaces all images
                       if (newImagesToUpload.isNotEmpty) {
                         try {
                            await editNotifier.updateImages(
                              productId: productId, // Pass the correct product ID
                              images: newImagesToUpload,
                              primaryImageIndex: primaryImageIndex.value,
                            );
                         } catch (e) {
                            imagesSuccess = false;
                            print("Error during updateImages call: $e");
                         }
                       } else if (existingImageUrls.isEmpty) {
                         // Handle case where all images were removed
                         try {
                           // Assuming updateImages with empty list removes all
                           await editNotifier.updateImages(productId: productId, images: [], primaryImageIndex: 0);
                         } catch (e) {
                           imagesSuccess = false;
                           print("Error during updateImages (removing all): $e");
                         }
                         print("All images removed.");
                       } else {
                         // Handle case where only primary index or order might have changed
                         // Requires API support or sending all existing URLs again with new index
                         print("Only primary index/order changed - Check API requirements.");
                         // Example: await editNotifier.updateImageOrderOrPrimary(productId, existingImageUrls, primaryImageIndex.value);
                       }
                    }

                    // Optionally pop only if everything succeeded
                    if (detailsSuccess && imagesSuccess && context.mounted) {
                       context.pop(); // Go back after successful save
                    }
                  },
                ),
        ],
      ),
      // Use AsyncValue.when for the INITIAL PRODUCT data loading
      body: productAsyncValue.when(
        skipLoadingOnRefresh: false, // Show loading on initial fetch/refresh
        data: (product) {
          // --- Pre-fill controllers and image state using useEffect ---
          // This runs when the 'product' data initially loads or changes.
          useEffect(() {
            print("useEffect triggered: Populating fields for product ID: ${product.id}");
            nameController.text = product.name;
            descriptionController.text = product.description;
            priceController.text = product.price.toStringAsFixed(2);
            stockController.text = product.stockQuantity.toString();
            // Only set the subcategory state hook if it hasn't been set by user interaction yet
            // or if the product data itself has changed fundamentally (new product loaded).
            // A simple check like this prevents overwriting user's dropdown changes during rebuilds.
            if (selectedSubCategoryId.value == null || selectedSubCategoryId.value != product.subCategoryId) {
                selectedSubCategoryId.value = product.subCategoryId;
            }

            // Initialize image list only once or if the product ID changes
            // This prevents overwriting picked images during rebuilds caused by state changes
            final isInitialLoad = images.value.isEmpty && product.imageUrls.isNotEmpty;
            if (isInitialLoad) {
                 images.value = List<dynamic>.from(product.imageUrls);
                 primaryImageIndex.value = 0; // Reset primary index
            }

            return null; // No cleanup needed
          // Dependency: Re-run if the product object instance changes.
          }, [product]);

          // --- UI ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              // key: formKey, // Add key if using validation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Form Fields ---
                  CustomTextField(labelText: l10n.productName, controller: nameController),
                  const SizedBox(height: 16),
                  // Category Dropdown
                  Consumer(builder: (context, ref, _) {
                    // Fetch subcategories based on the *product's main category ID*
                    final subCategoriesAsync = ref.watch(subCategoriesProvider(product.categoryId));
                    return subCategoriesAsync.when(
                      data: (subCats) {
                        final dropdownItems = subCats.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList();
                        // Validate current selection
                        final isValidValue = subCats.any((cat) => cat.id == selectedSubCategoryId.value);
                        // Use the state hook value for the dropdown
                        final dropdownValue = isValidValue ? selectedSubCategoryId.value : null;

                        return CustomDropdownField<int>(
                          key: ValueKey('subcategory_edit_${dropdownValue ?? 'null'}'),
                          labelText: l10n.category, // Or SubCategory?
                          hintText: l10n.categoryHint,
                          value: dropdownValue,
                          items: dropdownItems,
                          onChanged: (int? newValue) => selectedSubCategoryId.value = newValue,
                          validator: (value) => value == null ? l10n.validationRequired : null,
                        );
                      },
                      loading: () => Skeletonizer( // Skeleton for Dropdown
                        enabled: true,
                        child: CustomDropdownField<int>(
                          labelText: l10n.categoryLabel, hintText: l10n.categoryHint,
                          value: null, items: const [], onChanged: (v){},
                        ),
                      ),
                      error: (e,s) => Padding( // Error Display
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Error loading categories: $e', style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  CustomTextField(labelText: l10n.description, controller: descriptionController, maxLines: 4),
                  const SizedBox(height: 16),
                  Row( children: [
                       Expanded(child: CustomTextField(labelText: l10n.price, controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                       const SizedBox(width: 16),
                       Expanded(child: CustomTextField(labelText: l10n.stock, controller: stockController, keyboardType: TextInputType.number)),
                    ]
                  ),
                  const SizedBox(height: 24),

                  // --- Image Upload Section ---
                  Text(l10n.productImage, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100, // Adjust height as needed
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
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.dividerColor.withOpacity(0.5))
                              ),
                              child: Icon(Icons.add_photo_alternate_outlined, color: theme.colorScheme.primary, size: 30),
                            ),
                          );
                        }

                        // Image Tile
                        final item = images.value[index];
                        final bool isPrimary = index == primaryImageIndex.value;

                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                             GestureDetector( // Allow tapping to set primary
                               onTap: () => setPrimaryImage(index),
                               child: Container(
                                  width: 100, height: 100,
                                  padding: const EdgeInsets.all(2), // Padding to show border inside
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all( // Highlight primary
                                         color: isPrimary ? theme.colorScheme.primary : Colors.transparent,
                                         width: 3,
                                      ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9), // Inner radius smaller than container
                                    child: item is XFile // Check if it's a new file or existing URL
                                        ? Image.file(File(item.path), width: 94, height: 94, fit: BoxFit.cover)
                                        : Image.network(item as String, width: 94, height: 94, fit: BoxFit.cover,
                                            errorBuilder: (c,e,s) => Container(
                                              width: 94, height: 94, color: Colors.grey[300],
                                              child: Icon(Icons.broken_image, color: Colors.grey[600])
                                            )
                                          ),
                                  ),
                               ),
                             ),
                             // Remove button
                             InkWell(
                               onTap: () => removeImage(index),
                               child: Container(
                                 margin: const EdgeInsets.all(4), padding: const EdgeInsets.all(2),
                                 decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                 child: const Icon(Icons.close, color: Colors.white, size: 14),
                               ),
                             )
                          ],
                        );
                      },
                    ),
                  ),
                   const SizedBox(height: 8),
                   Text(
                      "Tap an image to set it as primary", // TODO: Localize
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                ],
              ),
            ),
          );
        },
        // --- Loading State ---
        loading: () => Skeletonizer( // Show skeleton during initial product load
           enabled: true,
           child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align labels left
              children: [
                 // Mimic form structure
                 Bone.text(width: 120), const SizedBox(height: 8), Bone(height: 50, borderRadius: BorderRadius.circular(12)), const SizedBox(height: 16),
                 Bone.text(width: 100), const SizedBox(height: 8), Bone(height: 50, borderRadius: BorderRadius.circular(12)), const SizedBox(height: 16), // Dropdown
                 Bone.text(width: 100), const SizedBox(height: 8), Bone(height: 100, borderRadius: BorderRadius.circular(12)), const SizedBox(height: 16), // Description
                 Row(children: [ Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Bone.text(width: 50), const SizedBox(height: 8), Bone(height: 50, borderRadius: BorderRadius.circular(12))])), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Bone.text(width: 50), const SizedBox(height: 8), Bone(height: 50, borderRadius: BorderRadius.circular(12))])) ]), // Price & Stock
                 const SizedBox(height: 24),
                 Bone.text(width: 150), const SizedBox(height: 8), // Images label
                 SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: List.generate(4, (index) => Padding(padding: const EdgeInsets.only(right: 8.0), child: Bone(width: 100, height: 100, borderRadius: BorderRadius.circular(12)))))), // Image list placeholder
              ],
            )),
          ),
        ),
        // --- Error State ---
        error: (e, st) => Center( // Show error if initial product load fails
           child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error loading product: $e", style: TextStyle(color: theme.colorScheme.error)), // TODO: Localize
          ),
        ),
      ),
    );
  }
}