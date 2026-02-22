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

                    // Premium theme picker
                    Row(
                      children: [
                        _ThemeCard(
                          mode: ThemeMode.light,
                          icon: FontAwesomeIcons.sun,
                          label: l10n.lightTheme,
                          selected: themeMode == ThemeMode.light,
                          accentColor: theme.colorScheme.primary,
                          bgColor: const Color(0xFFF5F5F5),
                          barColor: const Color(0xFFDDDDDD),
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.light),
                        ),
                        const SizedBox(width: 10),
                        _ThemeCard(
                          mode: ThemeMode.system,
                          icon: FontAwesomeIcons.circleHalfStroke,
                          label: l10n.systemTheme,
                          selected: themeMode == ThemeMode.system,
                          accentColor: theme.colorScheme.primary,
                          bgColor: const Color(0xFFE0E0E0),
                          barColor: const Color(0xFFBBBBBB),
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.system),
                        ),
                        const SizedBox(width: 10),
                        _ThemeCard(
                          mode: ThemeMode.dark,
                          icon: FontAwesomeIcons.moon,
                          label: l10n.darkTheme,
                          selected: themeMode == ThemeMode.dark,
                          accentColor: theme.colorScheme.primary,
                          bgColor: const Color(0xFF1E1E1E),
                          barColor: const Color(0xFF3A3A3A),
                          onTap: () => ref
                              .read(themeProvider.notifier)
                              .setTheme(ThemeMode.dark),
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
                    onTap: () async {
                      const url =
                          'https://www.facebook.com/profile.php?id=61582850605930';
                      if (!await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      )) {
                        debugPrint("Could not launch $url");
                      }
                    },
                  ),
                  _socialIcon(
                    FontAwesomeIcons.instagram,
                    const Color(0xFFE4405F),
                    onTap: () async {
                      const url = 'https://www.instagram.com/mens2.025/';
                      if (!await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      )) {
                        debugPrint("Could not launch $url");
                      }
                    },
                  ),
                  _socialIcon(
                    FontAwesomeIcons.whatsapp,
                    const Color(0xFF25D366),
                    onTap: () async {
                      const url = 'https://wa.me/201554367033';
                      if (!await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      )) {
                        debugPrint("Could not launch $url");
                      }
                    },
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
  Widget _socialIcon(IconData icon, Color bg, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// Small extension helper
extension _StringHelpers on String {
  String ifEmpty(String other) => trim().isEmpty ? other : this;
}

/// A tappable card that previews a theme mode (light / system / dark).
class _ThemeCard extends StatelessWidget {
  final ThemeMode mode;
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final Color bgColor;
  final Color barColor;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.bgColor,
    required this.barColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accentColor : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.30),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini UI preview
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                child: Container(
                  height: 56,
                  color: bgColor,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fake "header" bar
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Fake "content" bars
                      Container(
                        height: 6,
                        width: 40,
                        decoration: BoxDecoration(
                          color: barColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        width: 28,
                        decoration: BoxDecoration(
                          color: barColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Label + icon row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(11),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selected)
                      Icon(
                        FontAwesomeIcons.solidCircleCheck,
                        size: 11,
                        color: accentColor,
                      )
                    else
                      Icon(icon, size: 11, color: barColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected ? accentColor : barColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
