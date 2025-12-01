import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
// ✅ 1. Import AwesomeDialog
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/features/user/profile/notifiers/edit_profile_notifier.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Providers and State Hooks ---
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final profileState = ref.watch(editProfileNotifierProvider);
    final profileNotifier = ref.read(editProfileNotifierProvider.notifier);
    final currentLocale = ref.watch(
      localeProvider,
    ); // For DatePicker localization

    // Controllers
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final nationalIdController = useTextEditingController();
    final birthDateController = useTextEditingController();

    // ✅ 2. Updated State Listener for Save
    ref.listen(editProfileNotifierProvider, (previous, next) {
      // Don't show dialogs for the initial load sequence
      if (previous == null) {
        return;
      }

      // --- Handle Save Success ---
      if (previous is AsyncLoading && next is AsyncData) {
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: l10n.success,
            desc: l10n.profileSavedSuccess,
            btnOkOnPress: () {
              // Pop the screen after success
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ).show();
        }
      }
      // --- Handle Save Error ---
      else if (previous is AsyncLoading && next is AsyncError) {
        if (context.mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: l10n.error,
            desc: next.error.toString(), // Show the actual error
            btnOkOnPress: () {}, // Just dismiss
            btnOkColor: Colors.red,
          ).show();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          // This logic is correct: it shows a spinner during
          // initial load AND during the save operation.
          profileState.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  // Use a smaller indicator for the app bar
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    final updatedProfile = UserProfileData(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                      nationalId: nationalIdController.text.isNotEmpty
                          ? nationalIdController.text
                          : null,
                      birthDate: birthDateController.text.isNotEmpty
                          ? DateFormat(
                              'dd-MM-yyyy',
                            ).parse(birthDateController.text)
                          : null,
                    );
                    profileNotifier.saveChanges(updatedData: updatedProfile);
                  },
                ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          // Pre-fill controllers using useEffect
          useEffect(() {
            firstNameController.text = profile.firstName;
            lastNameController.text = profile.lastName;
            emailController.text = profile.email;
            phoneController.text = profile.phone;
            nationalIdController.text = profile.nationalId ?? '';
            birthDateController.text = profile.birthDate != null
                ? DateFormat('dd-MM-yyyy').format(profile.birthDate!)
                : '';
            return null; // No cleanup needed
          }, [profile]); // Dependency array

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  CustomTextField(
                    labelText: l10n.firstNameLabel,
                    controller: firstNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.lastNameLabel,
                    controller: lastNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.emailLabel,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.phone,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.nationalIdLabel,
                    controller: nationalIdController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // --- Birth Date Picker Field ---
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
                        controller: birthDateController,
                        readOnly: true, // Prevents keyboard from showing
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'dd-MM-yyyy',
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          DateTime initialDate;
                          try {
                            if (birthDateController.text.isNotEmpty) {
                              initialDate = DateFormat(
                                'dd-MM-yyyy',
                              ).parse(birthDateController.text);
                            } else {
                              initialDate = profile.birthDate ?? DateTime.now();
                            }
                          } catch (e) {
                            initialDate = profile.birthDate ?? DateTime.now();
                          }

                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            locale: currentLocale, // Use current app locale
                            initialDate: initialDate,
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
                            birthDateController.text = formattedDate;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        // Show loading skeleton
        loading: () => Skeletonizer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Use Bone widgets for placeholders
                const SizedBox(height: 24),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(height: 16),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(height: 16),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(height: 16),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(height: 16),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(height: 16),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
              ],
            ),
          ),
        ),
        // Show error with refresh
        error: (e, st) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(editProfileNotifierProvider);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Enable scrolling
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ), // Ensure it fills height
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
                            "Error loading profile: $e", // TODO: Localize
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
