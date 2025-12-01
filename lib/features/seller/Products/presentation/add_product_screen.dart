import 'dart:io'; // Required for FileImage
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart'; // Required for context.pop()
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Required for image picking
// ✅ 1. Import fluttertoast and localization
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/add_product_notifier.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/paginated_products_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/widgets/custom_dropdown.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../auth/notifiers/auth_notifier.dart'; // For loading skeleton

class AddProductScreen extends HookConsumerWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Providers and State ---
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final addProductState = ref.watch(addProductNotifierProvider);
    final addProductNotifier = ref.read(addProductNotifierProvider.notifier);

    // --- Form State using Hooks ---
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final priceController = useTextEditingController();
    final stockController = useTextEditingController();
    final selectedSubCategoryId = useState<int?>(
      null,
    ); // State for dropdown selection

    // --- Image State ---
    final mainImage = useState<XFile?>(null);
    final additionalImages = useState<List<XFile>>([]);
    final imagePicker = useMemoized(() => ImagePicker());

    // --- Functions ---
    // (Image picking functions are unchanged)
    Future<void> pickMainImage() async {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        mainImage.value = pickedImage;
      }
    }

    Future<void> pickAdditionalImages() async {
      final List<XFile> pickedImages = await imagePicker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        final currentPaths = additionalImages.value.map((f) => f.path).toSet();
        final newImages = pickedImages
            .where((f) => !currentPaths.contains(f.path))
            .toList();
        additionalImages.value = [...additionalImages.value, ...newImages];
      }
    }

    // ✅ 2. --- State Listener (Updated for Toasts) ---
    ref.listen(addProductNotifierProvider, (previous, next) {
      if (previous is AsyncLoading && next is AsyncData) {
        // --- Show Success Toast ---
        final successMsg = l10n.productAddedSuccess;
        Fluttertoast.showToast(
          msg: successMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Navigate back and refresh
        if (context.mounted) {
          context.pop(); // Go back to products screen
          Future.microtask(() {
            ref.invalidate(productsProvider);
            ref.read(paginatedProductsProvider.notifier).refresh();
            ref.read(paginatedAdminProductsProvider.notifier).refresh();
          });
        }
      } else if (next is AsyncError && !(next.isLoading)) {
        // --- Show Error Toast ---
        Fluttertoast.showToast(
          msg: "${l10n.errorAddingProduct}: ${next.error.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
          fontSize: 16.0,
        );
      }
    });

    // --- Build ---
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addProductTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey, // Assign form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Main Product Image ---
              Text(l10n.productImage, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Center(
                child: InkWell(
                  onTap: pickMainImage,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: mainImage.value == null
                        ? Stack(
                            // Placeholder with '+' icon
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: theme.hintColor,
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: colorScheme.primary,
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            // Show picked image preview
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(mainImage.value!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Form Fields ---
              CustomTextField(
                labelText: l10n.productName,
                controller: nameController,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.validationRequired : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // --- Category Dropdown (Fetches SubCategories) ---
              Consumer(
                builder: (context, ref, _) {
                  final authState = ref.watch(authNotifierProvider);
                  final userProfile = authState.asData?.value;
                  final subCategoriesAsync = ref.watch(
                    subCategoriesProvider(userProfile?.store?.categoryId ?? 1),
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
                      final isValidValue =
                          subCats.isNotEmpty &&
                          subCats.any(
                            (cat) => cat.id == selectedSubCategoryId.value,
                          );
                      final dropdownValue = isValidValue
                          ? selectedSubCategoryId.value
                          : null;

                      return CustomDropdownField<int>(
                        key: ValueKey(
                          'subcategory_dropdown_${dropdownValue ?? 'null'}',
                        ),
                        labelText:
                            l10n.category, // Use SubCategory Label if needed
                        hintText: l10n.categoryHint,
                        value: dropdownValue,
                        items: dropdownItems,
                        onChanged: (int? newValue) {
                          selectedSubCategoryId.value =
                              newValue; // Update local state hook
                        },
                        validator: (value) =>
                            value == null ? l10n.validationRequired : null,
                      );
                    },
                    loading: () => Skeletonizer(
                      // Skeleton for dropdown
                      enabled: true,
                      child: CustomDropdownField<int>(
                        labelText: l10n.category,
                        hintText: l10n.categoryHint,
                        value: null,
                        items: const [],
                        onChanged: (value) {},
                      ),
                    ),
                    error: (e, s) => Padding(
                      // Error display
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        l10n.errorLoadingCategories,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                },
              ),

              // --- End Category Dropdown ---
              const SizedBox(height: 16),
              CustomTextField(
                labelText: l10n.description,
                controller: descriptionController,
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.validationRequired : null,
                textInputAction: TextInputAction.next,
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
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.validationRequired;
                        }
                        final price = double.tryParse(v);
                        if (price == null || price <= 0) {
                          return 'Invalid Price'; // TODO: Localize
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      labelText: l10n.stock,
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.validationRequired;
                        }
                        final stock = int.tryParse(v);
                        if (stock == null || stock < 0) {
                          return 'Invalid Stock'; // TODO: Localize
                        }
                        return null;
                      },
                      textInputAction:
                          TextInputAction.done, // Last field before actions
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Additional Images ---
              Text(l10n.additionalImages, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      additionalImages.value.length +
                      1, // +1 for the add button
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    // The "Add More" button
                    if (index == additionalImages.value.length) {
                      return InkWell(
                        onTap: pickAdditionalImages,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              // Add a subtle border
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.1,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }
                    // Display a picked image
                    final image = additionalImages.value[index];
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(image.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Remove button
                        InkWell(
                          onTap: () {
                            // Create a new list without the item at the current index
                            final newList = List<XFile>.from(
                              additionalImages.value,
                            );
                            newList.removeAt(index);
                            additionalImages.value = newList;
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
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
              const SizedBox(height: 24),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // Disable button while loading
                  onPressed: addProductState.isLoading
                      ? null
                      : () {
                          // ✅ 3. ADDED VALIDATION TOASTS
                          void showErrorToast(String msg) {
                            Fluttertoast.showToast(
                              msg: msg,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: colorScheme.error,
                              textColor: colorScheme.onError,
                              fontSize: 16.0,
                            );
                          }

                          // Validate the form first
                          if (formKey.currentState?.validate() ?? false) {
                            if (mainImage.value == null) {
                              showErrorToast(l10n.pleaseAddMainImage);
                              return;
                            }
                            if (selectedSubCategoryId.value == null) {
                              showErrorToast(l10n.pleaseSelectCategory);
                              return;
                            }

                            // Combine main image and additional images
                            final allImages = [
                              mainImage.value!,
                              ...additionalImages.value,
                            ];

                            // Call the notifier to submit
                            addProductNotifier.submitProduct(
                              name: nameController.text,
                              description: descriptionController.text,
                              price: double.parse(
                                priceController.text,
                              ), // Already validated
                              stockQuantity: int.parse(
                                stockController.text,
                              ), // Already validated
                              subCategoryId: selectedSubCategoryId
                                  .value!, // Already validated
                              images: allImages,
                            );
                          } else {
                            showErrorToast(l10n.pleaseFixErrors);
                          }
                        },
                  // ✅ 4. UPDATED LOADING INDICATOR
                  child: addProductState.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(l10n.addProduct),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
