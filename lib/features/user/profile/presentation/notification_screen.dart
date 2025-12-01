import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/profile/notifiers/notifications_notifier.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final settings = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, l10n.pushNotifications),
          _buildSwitchTile(
            context: context,
            title: l10n.newOrders,
            value: settings.newOrdersPush,
            onChanged: notifier.toggleNewOrdersPush,
          ),
          _buildSwitchTile(
            context: context,
            title: l10n.promotionsAndUpdates,
            value: settings.promotionsPush,
            onChanged: notifier.togglePromotionsPush,
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, l10n.emailNotifications),
          _buildSwitchTile(
            context: context,
            title: l10n.newOrders,
            value: settings.newOrdersEmail,
            onChanged: notifier.toggleNewOrdersEmail,
          ),
          _buildSwitchTile(
            context: context,
            title: l10n.promotionsAndUpdates,
            value: settings.promotionsEmail,
            onChanged: notifier.togglePromotionsEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: SwitchListTile(
        title: Text(title, style: theme.textTheme.bodyLarge),
        value: value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}
