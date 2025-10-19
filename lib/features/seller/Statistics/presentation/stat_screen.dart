import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: "\$12,450",
                    label: l10n.totalSales,
                    change: "+23%",
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    value: "24",
                    label: l10n.products,
                    change: "+3",
                    icon: Icons.widgets_outlined,
                    iconColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatCard(
              value: "156",
              label: l10n.orders,
              change: "+12%",
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.purple,
              isFullWidth: true,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.monthlyOverview,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _OverviewRow(label: l10n.totalViews, value: "8,245"),
                  const Divider(height: 24),
                  _OverviewRow(label: l10n.newCustomers, value: "34"),
                  const Divider(height: 24),
                  _OverviewRow(label: l10n.revenue, value: "\$12,450"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets for the Dashboard
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.change,
    required this.icon,
    required this.iconColor,
    this.isFullWidth = false,
  });
  final String value, label, change;
  final IconData icon;
  final Color iconColor;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isFullWidth
          ? Center(child: _buildContent(textStyle, theme))
          : _buildContent(textStyle, theme),
    );
  }

  Widget _buildContent(TextTheme textStyle, ThemeData theme) {
    return Column(
      crossAxisAlignment: isFullWidth
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: textStyle.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textStyle.bodyMedium?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 4),
        Text(change, style: textStyle.bodySmall?.copyWith(color: Colors.green)),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
