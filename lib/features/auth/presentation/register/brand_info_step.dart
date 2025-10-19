import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/widgets/custom_dropdown.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';

class BrandInfoStep extends HookConsumerWidget {
  const BrandInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get providers
    final l10n = ref.watch(l10nProvider);
    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    final brandInfo = ref.watch(
      registerNotifierProvider.select((state) => state.brandInfo),
    );
    final theme = Theme.of(context);

    // Fetch subcategories for "Clothes" (ID 1)
    final subCategoriesAsyncValue = ref.watch(subCategoriesProvider(1));

    // Setup controllers
    final brandNameController = useTextEditingController(
      text: brandInfo.brandName,
    );
    final vatRegistrationNumberController = useTextEditingController(
      text: brandInfo.vatRegistrationNumber,
    );
    final descriptionController = useTextEditingController(
      text: brandInfo.description,
    );
    final locationController = useTextEditingController(
      text: brandInfo.location,
    );

    // Sync controllers with notifier (optional if using onChanged)
    // useEffect(() { ... }, []); // You can add listeners here if needed

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          labelText: l10n.brandNameLabel,
          controller: brandNameController,
          onChanged: (value) =>
              registerNotifier.updateBrandInfo(brandName: value),
          validator: (value) =>
              value == null || value.isEmpty ? l10n.validationRequired : null,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          labelText: l10n.vatRegistrationNumberLabel,
          controller: vatRegistrationNumberController,
          onChanged: (value) =>
              registerNotifier.updateBrandInfo(vatRegistrationNumber: value),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),

        // Category Dropdown (Updated Logic)
        subCategoriesAsyncValue.when(
          data: (subCategories) {
            // Check if subcategories were actually loaded
            if (subCategories.isEmpty) {
              return Text(
                'No subcategories found.', // Or a localized string
                style: TextStyle(color: theme.colorScheme.error),
              );
            }

            // Generate the items, ensuring no duplicate values internally
            final Set<int> seenIds = {};
            final List<DropdownMenuItem<int>> dropdownItems = [];
            for (var subCat in subCategories) {
              if (seenIds.add(subCat.id)) {
                // Add returns true if the ID was not already in the set
                dropdownItems.add(
                  DropdownMenuItem<int>(
                    value: subCat.id,
                    child: Text(subCat.name),
                  ),
                );
              } else {
                print(
                  "Warning: Duplicate subcategory ID ${subCat.id} found from API, skipping.",
                );
              }
            }

            // Validate the current value against the *unique* items list.
            final currentCategoryId = brandInfo.categoryId;
            final isValidValue = dropdownItems.any(
              (item) => item.value == currentCategoryId,
            );
            final dropdownValue = isValidValue
                ? currentCategoryId
                : null; // Use null if current ID is not in the list or is null

            // Diagnostic Print (Optional - remove after debugging)
            // print("Current Category ID: $currentCategoryId, Valid: $isValidValue, Dropdown Value: $dropdownValue, Items: ${dropdownItems.map((e) => e.value).toList()}");

            return CustomDropdownField<int>(
              labelText: l10n.categoryLabel,
              hintText: l10n.categoryHint,
              value: dropdownValue, // Use the validated value
              items: dropdownItems, // Use the unique list
              onChanged: (int? newValue) {
                registerNotifier.updateBrandInfo(categoryId: newValue);
              },
              validator: (value) =>
                  value == null ? l10n.validationRequired : null,
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Error loading categories: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),

        const SizedBox(height: 12),
        CustomTextField(
          labelText: l10n.descriptionLabel,
          controller: descriptionController,
          onChanged: (value) =>
              registerNotifier.updateBrandInfo(description: value),
          maxLines: 3, // Keep maxLines reasonable for the step layout
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          labelText: l10n.locationLabel,
          controller: locationController,
          onChanged: (value) =>
              registerNotifier.updateBrandInfo(location: value),
          textInputAction: TextInputAction.done, // Last field in this step
        ),
      ],
    );
  }
}
