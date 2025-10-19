import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              userProfile?.store?.brandImage ??
                  "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png",
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userProfile?.store?.brandName ?? "Store Name",
            style: theme.textTheme.titleLarge,
          ),
          Text(
            userProfile?.fullName ?? "Patner Name",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(context, ref),
          const SizedBox(height: 16),
          _buildActionList(context, l10n),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Column(
          children: [
            _InfoTile(
              icon: Icons.email_outlined,
              text: userProfile?.email ?? "Partner Mail",
            ),
            _InfoTile(
              icon: Icons.phone_outlined,
              text: userProfile?.phoneNumber ?? "Partner phone number",
            ),
            _InfoTile(
              icon: Icons.location_on_outlined,
              text: userProfile?.store?.location ?? "Patner Location",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionList(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Column(
          children: [
            _ActionTile(
              icon: Icons.person_outline,
              text: l10n.editProfile,
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _ActionTile(
              icon: Icons.store_outlined,
              text: l10n.shopInformation,
              onTap: () => context.push(AppRoutes.shopInformation),
            ),
            _ActionTile(
              icon: Icons.notifications_outlined,
              text: l10n.notifications,
              onTap: () => context.push(AppRoutes.notifications),
            ),
            _ActionTile(
              icon: Icons.help_outline_rounded,
              text: l10n.drawerHelpSupport,
              onTap: () => context.push(AppRoutes.helpSupport),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(text),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
