import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                  icon: const Icon(FontAwesomeIcons.check),
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
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _SectionHeader(title: l10n.profile),
                  _PremiumCard(
                    child: Column(
                      children: [
                        CustomTextField(
                          labelText: l10n.firstNameLabel,
                          controller: firstNameController,
                          prefixIcon: const Icon(FontAwesomeIcons.user, size: 16),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          labelText: l10n.lastNameLabel,
                          controller: lastNameController,
                          prefixIcon: const Icon(FontAwesomeIcons.user, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  _SectionHeader(title: l10n.contactUsTitle), // Using as 'Contact'
                  _PremiumCard(
                    child: Column(
                      children: [
                        CustomTextField(
                          labelText: l10n.emailLabel,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(FontAwesomeIcons.envelope, size: 16),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          labelText: l10n.phone,
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(FontAwesomeIcons.phone, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legal Information Section
                  _SectionHeader(title: l10n.legal),
                  _PremiumCard(
                    child: Column(
                      children: [
                        CustomTextField(
                          labelText: l10n.nationalIdLabel,
                          controller: nationalIdController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(FontAwesomeIcons.idCard, size: 16),
                        ),
                        const SizedBox(height: 16),
                        // --- Birth Date Picker Field ---
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.birthDateLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: birthDateController,
                              readOnly: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'dd-MM-yyyy',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(FontAwesomeIcons.calendar, size: 16),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              onTap: () async {
                                FocusScope.of(context).requestFocus(FocusNode());
                                DateTime initialDate;
                                try {
                                  if (birthDateController.text.isNotEmpty) {
                                    initialDate = DateFormat('dd-MM-yyyy')
                                        .parse(birthDateController.text);
                                  } else {
                                    initialDate =
                                        profile.birthDate ?? DateTime.now();
                                  }
                                } catch (e) {
                                  initialDate =
                                      profile.birthDate ?? DateTime.now();
                                }

                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  locale: currentLocale,
                                  initialDate: initialDate,
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  birthDateController.text =
                                      DateFormat('dd-MM-yyyy').format(pickedDate);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for fab or keyboard
                ],
              ),
            ),
          );
        },
        // Show loading skeleton
        loading: () => Skeletonizer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'PERSONAL'),
                _PremiumCard(
                  child: Column(
                    children: [
                      Container(height: 50, color: Colors.white24),
                      const SizedBox(height: 16),
                      Container(height: 50, color: Colors.white24),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'CONTACT'),
                _PremiumCard(
                  child: Column(
                    children: [
                      Container(height: 50, color: Colors.white24),
                      const SizedBox(height: 16),
                      Container(height: 50, color: Colors.white24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Show error with refresh
        error: (e, st) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(editProfileNotifierProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.circleExclamation,
                      color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text("Error loading profile: $e",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 12),
                  Text("Pull down to refresh", style: TextStyle(color: theme.hintColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- SHARED PREMIUM COMPONENTS ---
// Note: These should ideally be in shared/widgets, but replicated for speed/isolation

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.05),
        ),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
