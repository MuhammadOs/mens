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
    final colorScheme = theme.colorScheme;

    // Watch providers for theme and language
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          _buildDrawerHeader(context, ref),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, l10n.drawerLanguage),
                  RadioListTile<Locale>(
                    title: Text(
                      l10n.english,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: AppLocales.english,
                    groupValue: currentLocale,
                    onChanged: (locale) =>
                        ref.read(localeProvider.notifier).setLocale(locale!),
                    activeColor: colorScheme.primary,
                  ),
                  RadioListTile<Locale>(
                    title: Text(
                      l10n.arabic,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: AppLocales.arabic,
                    groupValue: currentLocale,
                    onChanged: (locale) =>
                        ref.read(localeProvider.notifier).setLocale(locale!),
                    activeColor: colorScheme.primary,
                  ),
                  _buildSectionHeader(context, l10n.drawerTheme),
                  RadioListTile<ThemeMode>(
                    title: Text(
                      l10n.lightTheme,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: ThemeMode.light,
                    groupValue: currentTheme,
                    onChanged: (themeMode) =>
                        ref.read(themeProvider.notifier).setTheme(themeMode!),
                    activeColor: colorScheme.primary,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(
                      l10n.darkTheme,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: ThemeMode.dark,
                    groupValue: currentTheme,
                    onChanged: (themeMode) =>
                        ref.read(themeProvider.notifier).setTheme(themeMode!),
                    activeColor: colorScheme.primary,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(
                      l10n.systemTheme,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    value: ThemeMode.system,
                    groupValue: currentTheme,
                    onChanged: (themeMode) =>
                        ref.read(themeProvider.notifier).setTheme(themeMode!),
                    activeColor: colorScheme.primary,
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.circleQuestion,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      l10n.drawerHelpSupport,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    trailing: Icon(
                      FontAwesomeIcons.chevronRight,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    onTap: () {
                      context.pop();
                      context.push(AppRoutes.helpSupport);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.addressBook,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      l10n.contactUsTitle,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    trailing: Icon(
                      FontAwesomeIcons.chevronRight,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    onTap: () {
                      context.pop();
                      final authState = ref.read(authNotifierProvider);
                      final role = (authState.asData?.value?.role ?? '')
                          .toString()
                          .toLowerCase();
                      if (role == 'admin') {
                        context.push(AppRoutes.adminConversations);
                      } else {
                        context.push(AppRoutes.contactUs);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, l10n.drawerFollowUs),
                  const SizedBox(height: 8),
                  // ✅ 2. Pass ref to buildSocialIcons
                  _buildSocialIcons(context, ref),
                ],
              ),
            ),
          ),
          // const Spacer(), // Removed Spacer to allow content to scroll
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
            child: InkWell(
              onTap: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.of(context).pop();
                context.go(AppRoutes.signIn);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(
                    0.5,
                  ), // A nice light red
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.arrowRightFromBracket,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.drawerLogOut,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    final theme = Theme.of(context);
    final brandImageUrl = userProfile?.store?.brandImage;

    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      accountName: Text(
        userProfile?.store?.brandName ?? "Brand Name",
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.surface,
        ),
      ),
      arrowColor: theme.colorScheme.onPrimary,
      onDetailsPressed: () {
        context.push(AppRoutes.sellerProfile);
      },
      accountEmail: Text(
        userProfile?.fullName ?? "Partner name",
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.surface,
        ),
      ),
      // ✅ 4. Dynamic brand image
      currentAccountPicture: CircleAvatar(
        backgroundColor: theme.colorScheme.onPrimary,
        // Show NetworkImage if URL exists, otherwise fall back to asset
        backgroundImage: (brandImageUrl != null && brandImageUrl.isNotEmpty)
            ? NetworkImage(brandImageUrl)
            : const AssetImage("assets/mens_logo.png") as ImageProvider,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ✅ 5. Helper function to launch URLs
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

  // ✅ 6. Updated social icons to be functional
  Widget _buildSocialIcons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(
          FontAwesomeIcons.facebook,
          const Color(0xFF1877F2),
          onTap: () async {
            const url =
                'https://www.facebook.com/profile.php?id=61582850605930';
            await _launchURL(ref, url);
          },
        ),
        _socialIcon(
          FontAwesomeIcons.instagram,
          const Color(0xFFE4405F),
          onTap: () async {
            const url = 'https://www.instagram.com/mens2.025/';
            await _launchURL(ref, url);
          },
        ),
        _socialIcon(
          FontAwesomeIcons.whatsapp,
          const Color(0xFF25D366),
          onTap: () async {
            const url = 'https://wa.me/201554367033';
            await _launchURL(ref, url);
          },
        ),
      ],
    );
  }

  // Helper Widget for Social Icons (Same as UserProfileScreen)
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
