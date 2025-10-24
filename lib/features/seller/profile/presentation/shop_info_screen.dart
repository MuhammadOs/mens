import 'dart:io'; // Required for FileImage if using local preview
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Required for image picking
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/features/seller/profile/notifiers/shop_info_notifier.dart';
import 'package:mens/shared/widgets/custom_dropdown.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Import Skeletonizer

class ShopInformationScreen extends HookConsumerWidget {
  const ShopInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Providers and State ---
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final shopInfoState = ref.watch(shopInfoNotifierProvider);
    final shopInfoNotifier = ref.read(shopInfoNotifierProvider.notifier);

    // Controllers
    final shopNameController = useTextEditingController();
    final vatController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final locationController = useTextEditingController();

    // Image Picker State
    final newImageFile = useState<XFile?>(
      null,
    ); // Stores the picked image temporarily
    final imagePicker = useMemoized(() => ImagePicker());

    // --- Functions ---
    // Function to pick an image and trigger upload
    Future<void> pickImage() async {
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        newImageFile.value = pickedImage; // Show preview immediately
        // Call notifier to handle the upload and state update
        await shopInfoNotifier.updateBrandImage(pickedImage);
        newImageFile.value =
            null; // Clear preview after upload attempt completes
      }
    }

    // --- State Listener ---
    // Listens for save success/failure messages from the notifier
    ref.listen(shopInfoNotifierProvider, (previous, next) {
      // Show success message on successful save (of text fields or image)
      if (previous?.isLoading == true && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Shop info saved!"),
            backgroundColor: Colors.green,
          ), // TODO: Localize
        );
      }
      // Show error message on failure
      else if (next is AsyncError && !(next.isLoading)) {
        // Only show error if not loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${next.error}"),
            backgroundColor: Colors.red,
          ), // TODO: Localize error
        );
      }
    });
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shopInformation),
        actions: [
          shopInfoState.maybeWhen(
            loading: () => (newImageFile.value == null)
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.check, color: Colors.grey),
                    onPressed: null,
                  ),
            orElse: () => IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                final currentShopInfo = ref
                    .read(shopInfoNotifierProvider)
                    .asData
                    ?.value;
                // TODO: Add form validation if needed using a Form widget + GlobalKey
                final updatedData = ShopInfoData(
                  shopName: shopNameController.text,
                  vatNumber: vatController.text,
                  categoryId:
                      currentShopInfo?.categoryId, // Use ID from current state
                  description: descriptionController.text,
                  location: locationController.text,
                  image: currentShopInfo?.image, // Pass current image URL
                );
                shopInfoNotifier.saveChanges(updatedData);
              },
            ),
          ),
        ],
      ),
      // Use AsyncValue.when to handle loading/error states for the main shop data
      body: shopInfoState.when(
        skipLoadingOnRefresh: false, // Ensure loading state is shown initially
        data: (shopInfo) {
          // Pre-fill controllers using useEffect to run when shopInfo data changes
          useEffect(
            () {
              shopNameController.text = shopInfo.shopName;
              vatController.text = shopInfo.vatNumber;
              descriptionController.text = shopInfo.description;
              locationController.text = shopInfo.location;
              // Category is handled directly in the dropdown's 'value'
              return null; // No cleanup needed
            },
            [shopInfo],
          ); // Dependency array ensures this runs when shopInfo data changes

          // Determine image source: new preview OR existing URL from shopInfo
          final imageToShow = newImageFile.value != null
              ? FileImage(File(newImageFile.value!.path))
                    as ImageProvider // Show preview
              : (shopInfo.image != null && shopInfo.image!.isNotEmpty
                    ? NetworkImage(shopInfo.image!) // Show fetched image
                    : null); // No image

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  // --- Brand Image Display and Picker ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme
                            .colorScheme
                            .surfaceContainerHighest, // Background if no image
                        backgroundImage: NetworkImage(
                          userProfile?.store?.brandImage ??
                              "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png",
                        ),
                        onBackgroundImageError: imageToShow is NetworkImage
                            ? (_, __) {
                                print(
                                  "Error loading network image: ${shopInfo.image}",
                                );
                                // Optionally show placeholder on error
                              }
                            : null,
                        child: userProfile?.store?.brandImage == null
                            ? Icon(
                                Icons.storefront,
                                size: 50,
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.5,
                                ),
                              )
                            : null, // Show icon only if no image
                      ),
                      // Show loading indicator specifically for image upload
                      if (shopInfoState.isLoading &&
                          newImageFile.value !=
                              null) // Check if specifically loading *after* picking
                        const Positioned.fill(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black54,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else // Show edit button otherwise
                        InkWell(
                          onTap: pickImage, // Allow picking a new image
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primary,
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Form Fields ---
                  CustomTextField(
                    labelText: l10n.brandNameLabel,
                    controller: shopNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.vatRegistrationNumberLabel,
                    controller: vatController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // --- Category Dropdown ---
                  Consumer(
                    builder: (context, ref, _) {
                      final categoriesAsync = ref.watch(
                        categoriesProvider,
                      ); // Fetch main categories
                      return categoriesAsync.when(
                        data: (categories) {
                          final dropdownItems = categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList();
                          // Validate directly against shopInfo from the outer .when
                          final isValidValue = categories.any(
                            (cat) => cat.id == shopInfo.categoryId,
                          );
                          final dropdownValue = isValidValue
                              ? shopInfo.categoryId
                              : null;

                          return CustomDropdownField<int>(
                            key: ValueKey(
                              'category_dropdown_${dropdownValue ?? 'null'}',
                            ),
                            labelText: l10n.categoryLabel,
                            hintText: l10n.categoryHint,
                            value:
                                dropdownValue, // Use validated value from shopInfo
                            items: dropdownItems,
                            onChanged:
                                null, // Disabled - category cannot be changed
                            validator: (value) =>
                                value == null ? l10n.validationRequired : null,
                          );
                        },
                        loading: () => Skeletonizer(
                          // Use Skeletonizer for dropdown loading
                          enabled: true,
                          child: CustomDropdownField<int>(
                            labelText: l10n.categoryLabel,
                            hintText: l10n.categoryHint,
                            value: null,
                            items: const [],
                            onChanged: (value) {}, // Disable during loading
                          ),
                        ),
                        error: (e, s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Error loading categories: $e',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      );
                    },
                  ),

                  // --- End Category Dropdown ---
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.descriptionLabel,
                    controller: descriptionController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.locationLabel,
                    controller: locationController,
                  ),
                ],
              ),
            ),
          );
        },
        // Show skeleton while initial shop info is fetched
        loading: () => const Skeletonizer(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  CircleAvatar(radius: 60),
                  SizedBox(height: 24),
                  CustomTextField(labelText: "Loading"),
                  SizedBox(height: 16),
                  CustomTextField(labelText: "Loading"),
                  // --- End Category Dropdown ---
                  SizedBox(height: 16),
                  CustomTextField(labelText: "Loading"),
                  SizedBox(height: 16),
                  CustomTextField(labelText: "Loading"),
                ],
              ),
            ),
          ),
        ),
        // Show error message if initial shop info fails to load, with pull-to-refresh
        error: (e, st) => RefreshIndicator(
          onRefresh: () async {
            // 1. Invalidate the provider to trigger a re-fetch
            ref.invalidate(shopInfoNotifierProvider);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error loading shop info: $e", // TODO: Localize
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Pull down to refresh", // TODO: Localize
                            style: TextStyle(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
