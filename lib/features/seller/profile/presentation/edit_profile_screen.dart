import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/features/seller/profile/notifiers/edit_profile_notifier.dart';
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

    // --- State Listener for Save ---
    ref.listen(editProfileNotifierProvider, (previous, next) {
      if (previous is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileSavedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        // Ensure context is still valid before popping
        if (context.mounted) {
          
        }
      } else if (next is AsyncError) {
        // Optionally show error on save failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving: ${next.error}"),
            backgroundColor: Colors.red,
          ), // TODO: Localize error
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          profileState.isLoading
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
                    if (kDebugMode) {
                      print("Updated birthdate: ${updatedProfile.birthDate}");
                    }
                  },
                ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          // Pre-fill controllers using useEffect to run only once or when profile changes
          useEffect(
            () {
              firstNameController.text = profile.firstName;
              lastNameController.text = profile.lastName;
              emailController.text = profile.email;
              phoneController.text = profile.phone;
              nationalIdController.text = profile.nationalId ?? '';
              birthDateController.text = profile.birthDate != null
                  ? DateFormat('dd-MM-yyyy').format(profile.birthDate!)
                  : '';
              return null; // No cleanup needed
            },
            [profile],
          ); // Dependency array ensures this runs when profile data changes

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  CustomTextField(
                    labelText: l10n.fullName,
                    controller: firstNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: l10n.fullName,
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
                          // Uses theme's InputDecorationTheme
                          hintText: 'dd-MM-yyyy',
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        onTap: () async {
                          // Hide keyboard if it somehow appears
                          FocusScope.of(context).requestFocus(FocusNode());
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            locale: currentLocale, // Use current app locale
                            initialDate: profile.birthDate ?? DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate:
                                DateTime.now(), // User cannot be born in the future
                            builder: (context, child) {
                              // Apply app's theme to the date picker dialog
                              return Theme(data: theme, child: child!);
                            },
                          );
                          if (pickedDate != null) {
                            final formattedDate = DateFormat(
                              'yyyy-MM-dd',
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
        // Show loading spinner while initial profile data is fetched
        loading: () => Skeletonizer(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              // Build a placeholder matching the form structure
              children: [
                CircleAvatar(radius: 60), // Placeholder for image
                SizedBox(height: 24),
                // Use Bone widgets (provided by Skeletonizer) for text field placeholders
                Bone.text(width: 100), // Label placeholder
                SizedBox(height: 8),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(height: 16),
                Bone.text(width: 100),
                SizedBox(height: 8),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(height: 16),
                Bone.text(width: 100),
                SizedBox(height: 8),
                Bone(
                  height: 50,
                  width: double.infinity,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                // Add more Bone widgets to match all fields in your form
              ],
            ),
          ),
        ),
        error: (e, st) => RefreshIndicator(
          onRefresh: () async {
            // Invalidate the provider to re-fetch the data
            ref.invalidate(editProfileNotifierProvider);
            // We don't need to await, RefreshIndicator handles the future
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight), // Ensure it fills height
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
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
