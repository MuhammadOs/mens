import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/shared/theme/theme_provider.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    return Drawer(
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ── Gradient header ─────────────────────────────────────────
          _DrawerHeader(userProfile: userProfile),

          // ── Scrollable body ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Language toggle ──────────────────────────────────
                  _SectionLabel(label: l10n.drawerLanguage),
                  const SizedBox(height: 8),
                  _SegmentedLangToggle(
                    leftLabel: l10n.english,
                    rightLabel: l10n.arabic,
                    isLeftSelected: currentLocale.languageCode == 'en',
                    accentColor: cs.primary,
                    onLeftTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(AppLocales.english),
                    onRightTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(AppLocales.arabic),
                  ),

                  const SizedBox(height: 20),

                  // ── Theme toggle ─────────────────────────────────────
                  _SectionLabel(label: l10n.drawerTheme),
                  const SizedBox(height: 8),
                  _ThemeToggleRow(
                    currentTheme: currentTheme,
                    accentColor: cs.primary,
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

                  const SizedBox(height: 20),

                  // ── Navigation tiles ─────────────────────────────────
                  _SectionLabel(label: l10n.drawerHelpSupport),
                  const SizedBox(height: 8),
                  _NavGroup(
                    tiles: [
                      _NavTileData(
                        icon: FontAwesomeIcons.circleQuestion,
                        label: l10n.drawerHelpSupport,
                        subtitle: 'FAQs & guides',
                        accentColor: const Color(0xFF5C6BC0),
                        onTap: () {
                          context.pop();
                          context.push(AppRoutes.helpSupport);
                        },
                      ),
                      _NavTileData(
                        icon: FontAwesomeIcons.addressBook,
                        label: l10n.contactUsTitle,
                        subtitle: 'Talk to our team',
                        accentColor: const Color(0xFF26A69A),
                        onTap: () {
                          context.pop();
                          final role =
                              (ref
                                          .read(authNotifierProvider)
                                          .asData
                                          ?.value
                                          ?.role ??
                                      '')
                                  .toLowerCase();
                          if (role == 'admin') {
                            context.push(AppRoutes.adminConversations);
                          } else {
                            context.push(AppRoutes.contactUs);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Social row ───────────────────────────────────────
                  _SectionLabel(label: l10n.drawerFollowUs),
                  const SizedBox(height: 12),
                  _SocialRow(ref: ref, launchURL: _launchURL),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Logout button ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: _LogoutButton(
              label: l10n.drawerLogOut,
              onTap: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.of(context).pop();
                context.go(AppRoutes.signIn);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(WidgetRef ref, String urlStr) async {
    final l10n = ref.read(l10nProvider);
    final theme = Theme.of(ref.context);
    final Uri url = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlStr';
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: l10n.errorCouldNotLaunchUrl,
        backgroundColor: theme.colorScheme.error,
        textColor: theme.colorScheme.onError,
      );
    }
  }
}

// ─── Drawer header ─────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final dynamic userProfile;
  const _DrawerHeader({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brandImageUrl = userProfile?.store?.brandImage as String?;
    final brandName = (userProfile?.store?.brandName as String?) ?? 'Brand';
    final ownerName = (userProfile?.fullName as String?) ?? '';
    final email = (userProfile?.email as String?) ?? '';
    final createdAt = userProfile?.createdAt as DateTime?;
    final memberYear = createdAt != null ? createdAt.year.toString() : '';
    final initials = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';
    final hasImage = brandImageUrl != null && brandImageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.sellerProfile),
      child: ClipPath(
        clipper: _WaveClipper(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.secondary,
                cs.secondary.withValues(alpha: 0.82),
                cs.primary.withValues(alpha: 0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Decorative circles ──────────────────────────────────
              Positioned(
                top: -30,
                right: -30,
                child: _DecorCircle(
                  size: 110,
                  opacity: 0.12,
                  color: cs.onPrimary,
                ),
              ),
              Positioned(
                top: 20,
                right: 40,
                child: _DecorCircle(
                  size: 55,
                  opacity: 0.08,
                  color: cs.onPrimary,
                ),
              ),
              Positioned(
                bottom: 10,
                left: -20,
                child: _DecorCircle(
                  size: 80,
                  opacity: 0.10,
                  color: cs.onPrimary,
                ),
              ),

              // ── Edit button top-right ────────────────────────────────
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.sellerProfile),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.penToSquare,
                      size: 14,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ),

              // ── Main content ─────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.sellerProfile),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.4),
                                width: 3,
                              ),
                            ),
                          ),
                          // Inner avatar
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.onPrimary.withValues(alpha: 0.22),
                              border: Border.all(color: cs.primary, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: hasImage
                                  ? DecorationImage(
                                      image: NetworkImage(brandImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !hasImage
                                ? Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: cs.onPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 30,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Brand name
                  Text(
                    brandName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  if (ownerName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ownerName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.80),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.envelope,
                          size: 9,
                          color: cs.onPrimary.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimary.withValues(alpha: 0.65),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Badges row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Seller badge
                      _HeaderBadge(
                        icon: FontAwesomeIcons.store,
                        label: 'Seller',
                        color: cs.onPrimary,
                      ),
                      if (memberYear.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _HeaderBadge(
                          icon: FontAwesomeIcons.calendarCheck,
                          label: 'Since $memberYear',
                          color: cs.onPrimary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeaderBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative translucent circle for background texture.
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;
  const _DecorCircle({
    required this.size,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

/// Clips the bottom of the header into a soft wave shape.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 16,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 32,
      size.width,
      size.height - 12,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}

// ─── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─── Segmented language toggle ─────────────────────────────────────────────────

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

// ─── Theme toggle row ──────────────────────────────────────────────────────────

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

// ─── Navigation group + tile ───────────────────────────────────────────────────

class _NavTileData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavTileData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });
}

class _NavGroup extends StatelessWidget {
  final List<_NavTileData> tiles;
  const _NavGroup({required this.tiles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            _NavTile(data: tiles[i]),
            if (i < tiles.length - 1)
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavTileData data;
  const _NavTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, size: 16, color: data.accentColor),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social icons row ─────────────────────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  final WidgetRef ref;
  final Future<void> Function(WidgetRef, String) launchURL;

  const _SocialRow({required this.ref, required this.launchURL});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIcon(
          icon: FontAwesomeIcons.facebook,
          bg: const Color(0xFF1877F2),
          onTap: () => launchURL(
            ref,
            'https://www.facebook.com/profile.php?id=61582850605930',
          ),
        ),
        const SizedBox(width: 16),
        _SocialIcon(
          icon: FontAwesomeIcons.instagram,
          bg: const Color(0xFFE4405F),
          onTap: () => launchURL(ref, 'https://www.instagram.com/mens2.025/'),
        ),
        const SizedBox(width: 16),
        _SocialIcon(
          icon: FontAwesomeIcons.whatsapp,
          bg: const Color(0xFF25D366),
          onTap: () => launchURL(ref, 'https://wa.me/201554367033'),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.38),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ─── Logout button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LogoutButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                errorColor.withValues(alpha: 0.14),
                errorColor.withValues(alpha: 0.07),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: errorColor.withValues(alpha: 0.35)),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.arrowRightFromBracket,
                  color: errorColor,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: errorColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
