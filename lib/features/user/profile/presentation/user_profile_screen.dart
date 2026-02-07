import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/shared/theme/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.asData?.value;
    // Check for guest by userId == 0
    final isGuest = user?.userId == 0;

    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              if (isGuest) ...[
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.cardColor,
                  child: Icon(
                    FontAwesomeIcons.userSecret,
                    size: 40,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.continueAsGuest,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.loginPageTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.dontHaveAccount,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).logout();
                            context.go(AppRoutes.signIn);
                          },
                          child: Text(l10n.loginButton),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // Avatar + Names
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.cardColor,
                  backgroundImage: user?.store?.brandImage != null
                      ? NetworkImage(user!.store!.brandImage!) as ImageProvider
                      : null,
                  child: user?.store?.brandImage == null
                      ? Icon(
                          FontAwesomeIcons.user,
                          size: 40,
                          color: theme.colorScheme.onSurface,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ??
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}'
                          .trim()
                          .ifEmpty('Guest'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? l10n.emailLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.profile,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.push(AppRoutes.editProfile),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.penToSquare,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.editProfile,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        l10n.firstNameLabel,
                        user?.firstName ?? '',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        l10n.emailLabel,
                        user?.email ?? '',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        l10n.userNameLabel,
                        user?.phoneNumber ?? '',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Settings Card (Visible for both)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.gear,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.setupPageTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Theme toggle
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.sun,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.theme,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                themeMode == ThemeMode.dark
                                    ? l10n.darkTheme
                                    : (themeMode == ThemeMode.light
                                          ? l10n.lightTheme
                                          : l10n.systemTheme),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: themeMode == ThemeMode.dark,
                          activeTrackColor: theme.colorScheme.primary,
                          onChanged: (val) => ref
                              .read(themeProvider.notifier)
                              .setTheme(val ? ThemeMode.dark : ThemeMode.light),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Language selector
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.globe,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.language,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                locale.languageCode == 'ar'
                                    ? l10n.arabic
                                    : l10n.english,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Locale>(
                              value: locale,
                              dropdownColor: theme.scaffoldBackgroundColor,
                              items: AppLocales.supported.map((loc) {
                                final label = loc.languageCode == 'ar'
                                    ? l10n.arabic
                                    : l10n.english;
                                return DropdownMenuItem(
                                  value: loc,
                                  child: Text(label),
                                );
                              }).toList(),
                              onChanged: (newLocale) async {
                                if (newLocale == null) return;
                                await ref
                                    .read(localeProvider.notifier)
                                    .setLocale(newLocale);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Support card
              if (user?.role != "Admin" && !isGuest) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.envelope,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.contactUsTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            final authState = ref.read(authNotifierProvider);
                            final user = authState.asData?.value;
                            final role = (user?.role ?? '')
                                .toString()
                                .toLowerCase();
                            if (role == 'admin') {
                              context.push(AppRoutes.adminConversations);
                            } else {
                              context.push(AppRoutes.contactUs);
                            }
                          },
                          child: Text(
                            l10n.contactUsTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Legal Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.shieldHalved,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.legal,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(
                          'https://mens-shop-api-fhgf2.ondigitalocean.app/privacy-policy.html',
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not launch Privacy Policy',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.privacyPolicy,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Icon(
                            FontAwesomeIcons.arrowUpRightFromSquare,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(
                    FontAwesomeIcons.facebook,
                    const Color(0xFF1877F2),
                  ),
                  _socialIcon(
                    FontAwesomeIcons.instagram,
                    const Color(0xFFE4405F),
                  ),
                  _socialIcon(
                    FontAwesomeIcons.whatsapp,
                    const Color(0xFF25D366),
                  ),
                ],
              ),

              if (!isGuest) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    // Logout
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.signIn);
                  },
                  child: Text(
                    l10n.drawerLogOut,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Info Rows
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Helper Widget for Social Icons
  Widget _socialIcon(IconData icon, Color bg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

// Small extension helper
extension _StringHelpers on String {
  String ifEmpty(String other) => trim().isEmpty ? other : this;
}
