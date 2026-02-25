import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/profile/notifiers/checkout_preferences_notifier.dart';
import 'package:mens/shared/widgets/app_back_button.dart';

class CheckoutPreferencesScreen extends HookConsumerWidget {
  const CheckoutPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    // Watch the current preferences to populate the controllers initially
    final currentPrefs = ref.watch(checkoutPreferencesProvider);

    final cityController = useTextEditingController(text: currentPrefs.city);
    final streetController = useTextEditingController(text: currentPrefs.street);
    final buildingController = useTextEditingController(text: currentPrefs.building);
    final floorController = useTextEditingController(text: currentPrefs.floor);
    final flatController = useTextEditingController(text: currentPrefs.flat);
    final notesController = useTextEditingController(text: currentPrefs.notes);

    // Track unsaved changes loosely to enable/disable button
    final hasChanges = useState(false);

    // Whenever a text field changes, update hasChanges
    void checkChanges() {
      final changed = cityController.text != currentPrefs.city ||
          streetController.text != currentPrefs.street ||
          buildingController.text != currentPrefs.building ||
          floorController.text != currentPrefs.floor ||
          flatController.text != currentPrefs.flat ||
          notesController.text != currentPrefs.notes;
      if (hasChanges.value != changed) {
        hasChanges.value = changed;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkoutPreferences),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppBackButton(
            outlined: true,
            iconColor: theme.appBarTheme.foregroundColor ?? Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.defaultShippingAddress,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.saveShippingDetailsDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    l10n.city,
                    cityController,
                    onChanged: (_) => checkChanges(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    l10n.street,
                    streetController,
                    onChanged: (_) => checkChanges(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    l10n.building,
                    buildingController,
                    onChanged: (_) => checkChanges(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    l10n.floor,
                    floorController,
                    onChanged: (_) => checkChanges(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    l10n.flat,
                    flatController,
                    onChanged: (_) => checkChanges(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              l10n.additionalNotes,
              notesController,
              maxLines: 3,
              onChanged: (_) => checkChanges(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: hasChanges.value
                    ? () async {
                        await ref
                            .read(checkoutPreferencesProvider.notifier)
                            .updatePreferences(
                              city: cityController.text,
                              street: streetController.text,
                              building: buildingController.text,
                              floor: floorController.text,
                              flat: flatController.text,
                              notes: notesController.text,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.preferencesSavedSuccess),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Reset the changes state now that it's synced
                          hasChanges.value = false;
                        }
                      }
                    : null,
                icon: const Icon(FontAwesomeIcons.floppyDisk, size: 18),
                label: Text(l10n.savePreferences),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: maxLines > 1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
