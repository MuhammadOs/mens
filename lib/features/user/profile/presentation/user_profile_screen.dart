import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/shared/theme/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return authState.when(
      data: (user) {
        final isGuest = user?.userId == 0;
        return _buildProfileContent(context, ref, user, isGuest, themeMode, locale);
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: _buildProfileContent(context, ref, null, false, themeMode, locale),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(authNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    dynamic user, // User?
    bool isGuest,
    ThemeMode themeMode,
    Locale locale,
  ) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Premium Profile Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: theme.brightness == Brightness.dark
                            ? [
                                theme.colorScheme.surface,
                                theme.colorScheme.surface.withValues(alpha: 0.8),
                                theme.scaffoldBackgroundColor,
                              ]
                            : [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withValues(alpha: 0.8),
                                theme.colorScheme.secondary,
                              ],
                      ),
                    ),
                  ),
                  // Background Pattern (Subtle)
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Icon(
                      FontAwesomeIcons.circleUser,
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  // Header Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Avatar
                      Hero(
                        tag: 'user_avatar',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage:
                                !isGuest && user?.store?.brandImage != null
                                    ? NetworkImage(user!.store!.brandImage!)
                                    : null,
                            child: isGuest || user?.store?.brandImage == null
                                ? Icon(
                                    isGuest
                                        ? FontAwesomeIcons.userSecret
                                        : FontAwesomeIcons.user,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Names
                      Text(
                        isGuest
                            ? l10n.continueAsGuest
                            : user?.fullName ??
                                '${user?.firstName ?? ''} ${user?.lastName ?? ''}'
                                    .trim()
                                    .ifEmpty('User'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isGuest) ...[
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Profile Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isGuest) ...[
                      // Guest Login Prompt
                      _PremiumCard(
                        child: Column(
                          children: [
                            Icon(
                              FontAwesomeIcons.rightToBracket,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.loginPageTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.dontHaveAccount,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .logout();
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
                      // Account Information Section
                      _SectionHeader(title: l10n.profile),
                      _PremiumCard(
                        child: Column(
                          children: [
                            _InfoTile(
                              icon: FontAwesomeIcons.user,
                              label: l10n.firstNameLabel,
                              value: user?.firstName ?? '',
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8),child: _Divider(),),
                            _InfoTile(
                              icon: FontAwesomeIcons.envelope,
                              label: l10n.emailLabel,
                              value: user?.email ?? '',
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8),child: _Divider(),),
                            _InfoTile(
                              icon: FontAwesomeIcons.phone,
                              label: l10n.phoneNumberLabel,
                              value: user?.phoneNumber ?? '',
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    context.push(AppRoutes.editProfile),
                                icon: const Icon(FontAwesomeIcons.penToSquare,
                                    size: 14),
                                label: Text(l10n.editProfile),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Settings Section
                    _SectionHeader(title: l10n.setupPageTitle),
                    _PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Theme Toggle
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ThemeToggleRow(
                              currentTheme: themeMode,
                              accentColor: theme.colorScheme.primary,
                              lightLabel: l10n.lightTheme,
                              systemLabel: l10n.systemTheme,
                              darkLabel: l10n.darkTheme,
                              onLight: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(ThemeMode.light),
                              onSystem: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(ThemeMode.system),
                              onDark: () => ref
                                  .read(themeProvider.notifier)
                                  .setTheme(ThemeMode.dark),
                            ),
                          ),
                          const _Divider(),
                          _SettingsTile(
                            icon: FontAwesomeIcons.lock,
                            title: l10n.changePasswordTitle,
                            onTap: () => context.push(AppRoutes.changePassword),
                          ),
                          const _Divider(),
                          _SettingsTile(
                            icon: FontAwesomeIcons.truckFast,
                            title: l10n.checkoutPreferences,
                            onTap: () =>
                                context.push(AppRoutes.checkoutPreferences),
                          ),
                          const _Divider(),
                          // Language Selector
                          _LanguageTile(
                            currentLocale: locale,
                            onChanged: (newLocale) async {
                              if (newLocale == null) return;
                              await ref
                                  .read(localeProvider.notifier)
                                  .setLocale(newLocale);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Support Section
                    if (user?.role != "Admin" && !isGuest) ...[
                      _PremiumCard(
                        child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(FontAwesomeIcons.headset,
                                    size: 16),
                                label: Text(l10n.contactUsTitle),
                                onPressed: () {
                                  final role = (user?.role ?? '')
                                      .toString()
                                      .toLowerCase();
                                  if (role == 'admin') {
                                    context.push(AppRoutes.adminConversations);
                                  } else {
                                    context.push(AppRoutes.contactUs);
                                  }
                                },
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Legal Section
                    _SectionHeader(title: l10n.legal),
                    _PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: FontAwesomeIcons.shieldHalved,
                            title: l10n.privacyPolicy,
                            trailing: const Icon(
                                FontAwesomeIcons.arrowUpRightFromSquare,
                                size: 12),
                            onTap: () async {
                              final Uri url = Uri.parse(
                                'https://mens-shop-api-fhgf2.ondigitalocean.app/privacy-policy.html',
                              );
                              if (!await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Could not launch Privacy Policy')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Socials
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIcon(
                          icon: FontAwesomeIcons.facebook,
                          color: const Color(0xFF1877F2),
                          onTap: () => launchUrl(
                              Uri.parse(
                                  'https://www.facebook.com/profile.php?id=61582850605930'),
                              mode: LaunchMode.externalApplication),
                        ),
                        _SocialIcon(
                          icon: FontAwesomeIcons.instagram,
                          color: const Color(0xFFE4405F),
                          onTap: () => launchUrl(
                              Uri.parse('https://www.instagram.com/mens2.025/'),
                              mode: LaunchMode.externalApplication),
                        ),
                        _SocialIcon(
                          icon: FontAwesomeIcons.whatsapp,
                          color: const Color(0xFF25D366),
                          onTap: () => launchUrl(
                              Uri.parse('https://wa.me/201554367033'),
                              mode: LaunchMode.externalApplication),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    if (!isGuest)
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .logout();
                            if (context.mounted) context.go(AppRoutes.signIn);
                          },
                          icon: Icon(FontAwesomeIcons.rightFromBracket,
                              color: theme.colorScheme.error, size: 16),
                          label: Text(
                            l10n.drawerLogOut,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// --- PREMIUM HELPER WIDGETS ---

class _PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _PremiumCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.ifEmpty('-'),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            trailing ?? Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  final Locale currentLocale;
  final ValueChanged<Locale?> onChanged;

  const _LanguageTile({required this.currentLocale, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.globe,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text(
                l10n.language.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SegmentedLangToggle(
            leftLabel: l10n.english,
            rightLabel: l10n.arabic,
            isLeftSelected: currentLocale.languageCode == 'en',
            accentColor: theme.colorScheme.primary,
            onLeftTap: () => onChanged(const Locale('en')),
            onRightTap: () => onChanged(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

// ─── Segmented Language Toggle ─────────────────────────────────────────────────

class _SegmentedLangToggle extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final Color accentColor;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  const _SegmentedLangToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.accentColor,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.onSurface.withValues(alpha: 0.06);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            label: leftLabel,
            selected: isLeftSelected,
            accentColor: accentColor,
            isLeft: true,
            onTap: onLeftTap,
          ),
          _Segment(
            label: rightLabel,
            selected: !isLeftSelected,
            accentColor: accentColor,
            isLeft: false,
            onTap: onRightTap,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accentColor;
  final bool isLeft;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Theme Toggle Row ──────────────────────────────────────────────────────────

class _ThemeToggleRow extends StatelessWidget {
  final ThemeMode currentTheme;
  final Color accentColor;
  final String lightLabel;
  final String systemLabel;
  final String darkLabel;
  final VoidCallback onLight;
  final VoidCallback onSystem;
  final VoidCallback onDark;

  const _ThemeToggleRow({
    required this.currentTheme,
    required this.accentColor,
    required this.lightLabel,
    required this.systemLabel,
    required this.darkLabel,
    required this.onLight,
    required this.onSystem,
    required this.onDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.onSurface.withValues(alpha: 0.06);
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ThemeOption(
            icon: FontAwesomeIcons.sun,
            label: lightLabel,
            selected: currentTheme == ThemeMode.light,
            accentColor: accentColor,
            onTap: onLight,
          ),
          _ThemeOption(
            icon: FontAwesomeIcons.circleHalfStroke,
            label: systemLabel,
            selected: currentTheme == ThemeMode.system,
            accentColor: accentColor,
            onTap: onSystem,
          ),
          _ThemeOption(
            icon: FontAwesomeIcons.moon,
            label: darkLabel,
            selected: currentTheme == ThemeMode.dark,
            accentColor: accentColor,
            onTap: onDark,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.05),
    );
  }
}

// Small extension helper
extension _StringHelpers on String {
  String ifEmpty(String other) => trim().isEmpty ? other : this;
}
