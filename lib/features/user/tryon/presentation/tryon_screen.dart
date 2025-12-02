import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';

class TryOnScreen extends ConsumerWidget {
  const TryOnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // 1. Watch the localization provider
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(l10n.tryOnTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            // 3. Use localized "Under construction"
            Text(
              l10n.underConstructionTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // 4. Use localized "Coming soon"
            Text(l10n.comingSoonMessage, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
