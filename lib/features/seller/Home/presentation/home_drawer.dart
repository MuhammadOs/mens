import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          Padding(
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
                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  title: Text(
                    l10n.drawerHelpSupport,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onTap: () {
                    context.pop();
                    context.push(AppRoutes.helpSupport);
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionHeader(context, l10n.drawerFollowUs),
                const SizedBox(height: 8),
                _buildSocialIcons(context),
              ],
            ),
          ),
          const Spacer(),
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
                    Icon(Icons.logout, color: theme.colorScheme.error),
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
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      accountName: Text(
        userProfile?.store?.brandName ?? "Brand Name",
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.surface,
        ),
      ),
      arrowColor: theme.colorScheme.primary,
      onDetailsPressed: () {
        context.push("/profile");
      },
      accountEmail: Text(
        userProfile?.fullName ?? "Partner name",
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.surface,
        ),
      ),
      currentAccountPicture: const CircleAvatar(
        backgroundImage: AssetImage(
          "assets/mens_logo.png",
        ), // Replace with actual brand logo
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

  Widget _buildSocialIcons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TODO: Add onTap handlers
        IconButton(
          icon: const Icon(Icons.facebook),
          color: theme.colorScheme.primary,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined),
          color: theme.colorScheme.primary,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          color: theme.colorScheme.primary,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.close),
          color: theme.colorScheme.primary,
          onPressed: () {},
        ),
      ],
    );
  }
}
