import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
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
            userProfile?.store?.brandName ?? "Brand Name",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            userProfile?.fullName ?? "Patner Name",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(context, ref),
          const SizedBox(height: 16),
          _buildActionList(context, ref, l10n),
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
              icon: FontAwesomeIcons.envelope,
              text: userProfile?.email ?? "Partner Mail",
            ),
            _InfoTile(
              icon: FontAwesomeIcons.phone,
              text: userProfile?.phoneNumber ?? "Partner phone number",
            ),
            _InfoTile(
              icon: FontAwesomeIcons.locationDot,
              text: userProfile?.store?.location ?? "Patner Location",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Column(
          children: [
            _ActionTile(
              icon: FontAwesomeIcons.user,
              text: l10n.editProfile,
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _ActionTile(
              icon: FontAwesomeIcons.store,
              text: l10n.shopInformation,
              onTap: () => context.push(AppRoutes.shopInformation),
            ),
            _ActionTile(
              icon: FontAwesomeIcons.bell,
              text: l10n.notifications,
              onTap: () => context.push(AppRoutes.notifications),
            ),
            _ActionTile(
              icon: FontAwesomeIcons.circleQuestion,
              text: l10n.drawerHelpSupport,
              onTap: () => context.push(AppRoutes.helpSupport),
            ),
            _ActionTile(
              icon: FontAwesomeIcons.addressBook,
              text: l10n.contactUsTitle,
              onTap: () {
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
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
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
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        FontAwesomeIcons.chevronRight,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
