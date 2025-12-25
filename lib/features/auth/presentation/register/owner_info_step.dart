import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';

class OwnerInfoStep extends HookConsumerWidget {
  const OwnerInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get providers
    final l10n = ref.watch(l10nProvider);
    final currentLocale = ref.watch(localeProvider);
    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    final ownerInfo = ref.watch(
      registerNotifierProvider.select((state) => state.ownerInfo),
    );
    final theme = Theme.of(context);

    // Setup controllers using hooks
    final firstNameController = useTextEditingController(
      text: ownerInfo.firstName,
    );
    final lastNameController = useTextEditingController(
      text: ownerInfo.lastName,
    );
    final nationalIdController = useTextEditingController(
      text: ownerInfo.nationalId,
    );
    final phoneController = useTextEditingController(
      text: ownerInfo.phoneNumber,
    );
    final dateController = useTextEditingController(
      text: ownerInfo.birthDate != null
          ? DateFormat('yyyy-MM-dd').format(ownerInfo.birthDate!)
          : '',
    );

    return Form(
      // You can wrap this in a Form with a GlobalKey if you want to validate on 'Next' button press
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: l10n.firstNameLabel,
                    controller: firstNameController,
                    onChanged: (value) =>
                        registerNotifier.updateOwnerInfo(firstName: value),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.validationRequired
                        : null,
                    textInputAction: TextInputAction.next,
                    textDirection: ui.TextDirection.ltr,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    labelText: l10n.lastNameLabel,
                    controller: lastNameController,
                    onChanged: (value) =>
                        registerNotifier.updateOwnerInfo(lastName: value),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.validationRequired
                        : null,
                    textInputAction: TextInputAction.next,
                    textDirection: ui.TextDirection.ltr,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              labelText: l10n.nationalIdLabel,
              controller: nationalIdController,
              onChanged: (value) =>
                  registerNotifier.updateOwnerInfo(nationalId: value),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              textDirection: ui.TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              labelText: l10n.phone,
              controller: phoneController,
              onChanged: (value) =>
                  registerNotifier.updateOwnerInfo(phoneNumber: value),
              validator: (value) => value == null || value.isEmpty
                  ? l10n.validationRequired
                  : null,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              textDirection: ui.TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            // Date Picker Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.birthDateLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: Icon(
                      FontAwesomeIcons.calendar,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      locale: currentLocale,
                      initialDate: ownerInfo.birthDate ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(data: theme, child: child!);
                      },
                    );
                    if (pickedDate != null) {
                      final formattedDate = DateFormat(
                        'dd-MM-yyyy',
                      ).format(pickedDate);
                      dateController.text = formattedDate;
                      registerNotifier.updateOwnerInfo(birthDate: pickedDate);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
