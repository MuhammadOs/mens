import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/features/seller/categories/domain/category.dart';
import 'package:mens/shared/widgets/custom_dropdown.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

    // Fetch main categories
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    // Create controllers once
    final brandNameController = useMemoized(
      () => TextEditingController(text: brandInfo.brandName),
    );
    final vatRegistrationNumberController = useMemoized(
      () => TextEditingController(text: brandInfo.vatRegistrationNumber),
    );
    final descriptionController = useMemoized(
      () => TextEditingController(text: brandInfo.description),
    );
    final locationController = useMemoized(
      () => TextEditingController(text: brandInfo.location),
    );

    // Sync controllers with state changes (e.g., when navigating back to this step)
    // but only if the controller text differs from state (avoid cursor reset during typing)
    useEffect(() {
      if (brandNameController.text != brandInfo.brandName) {
        brandNameController.text = brandInfo.brandName;
      }
      if (vatRegistrationNumberController.text !=
          brandInfo.vatRegistrationNumber) {
        vatRegistrationNumberController.text = brandInfo.vatRegistrationNumber;
      }
      if (descriptionController.text != brandInfo.description) {
        descriptionController.text = brandInfo.description;
      }
      if (locationController.text != brandInfo.location) {
        locationController.text = brandInfo.location;
      }
      return null;
    }, [brandInfo]);

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left, // Explicitly left-aligned for LTR
            labelText: l10n.brandNameLabel,
            hintText: l10n.brandNameHint,
            controller: brandNameController,
            onChanged: (value) =>
                registerNotifier.updateBrandInfo(brandName: value),
            validator: (value) =>
                value == null || value.isEmpty ? l10n.validationRequired : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            // FIX: Added textDirection
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left, // Explicitly left-aligned for LTR
            labelText: l10n.vatRegistrationNumberLabel,
            controller: vatRegistrationNumberController,
            onChanged: (value) =>
                registerNotifier.updateBrandInfo(vatRegistrationNumber: value),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),

          // Category Dropdown
          categoriesAsyncValue.when(
            data: (categories) {
              final dropdownItems = categories.map((Category cat) {
                return DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList();

              final currentCategoryId = brandInfo.categoryId;
              final isValidValue = categories.any(
                (cat) => cat.id == currentCategoryId,
              );
              final dropdownValue = isValidValue ? currentCategoryId : null;

              return CustomDropdownField<int>(
                labelText: l10n.categoryLabel,
                hintText: l10n.categoryHint,
                value: dropdownValue,
                items: dropdownItems,
                onChanged: (int? newValue) {
                  registerNotifier.updateBrandInfo(categoryId: newValue);
                },
                validator: (value) =>
                    value == null ? l10n.validationRequired : null,
              );
            },
            loading: () => Skeletonizer(
              enabled: true,
              child: CustomDropdownField<int>(
                labelText: l10n.categoryLabel,
                hintText: l10n.categoryHint,
                value: null,
                items: const [],
                onChanged: (value) {}, // Disabled
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
            // FIX: Added textDirection
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left, // Explicitly left-aligned for LTR
            labelText: l10n.descriptionLabel,
            controller: descriptionController,
            onChanged: (value) =>
                registerNotifier.updateBrandInfo(description: value),
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            // FIX: Added textDirection
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left, // Explicitly left-aligned for LTR
            labelText: l10n.locationLabel,
            hintText: l10n.locationHint,
            controller: locationController,
            onChanged: (value) =>
                registerNotifier.updateBrandInfo(location: value),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
