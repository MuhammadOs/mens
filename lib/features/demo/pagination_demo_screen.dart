import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaginationDemoScreen extends ConsumerWidget {
  const PaginationDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Demo'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pagination Implementation',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Two pagination approaches have been implemented:',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Original Products Screen
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.list_alt,
                  color: theme.colorScheme.secondary,
                ),
                title: const Text('Original Products (Load All)'),
                subtitle: const Text(
                  'Uses the original approach - loads all products at once',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/products'),
              ),
            ),
            const SizedBox(height: 12),

            // Paginated Products Screen
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.view_list,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Paginated Products (NEW)'),
                subtitle: const Text(
                  'Uses pagination with page controls and infinite scroll',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
                onTap: () => context.push('/paginated-products'),
              ),
            ),
            const SizedBox(height: 12),

            // Admin Products (with pagination)
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.tertiary,
                ),
                title: const Text('Admin Products (Paginated)'),
                subtitle: const Text(
                  'Admin view showing all products with pagination',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/admin'),
              ),
            ),

            const SizedBox(height: 32),

            // Features section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pagination Features:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildFeatureList(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(ThemeData theme) {
    final features = [
      '📄 Page-based navigation with controls',
      '🔄 Infinite scroll with "Load More" button',
      '📊 Items count and pagination info',
      '🎯 Filter support by subcategory',
      '🔄 Pull-to-refresh functionality',
      '💾 Efficient memory usage',
      '🌐 Localized pagination text',
      '📱 Responsive design',
    ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  feature.split(' ')[0], // Emoji
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature.substring(feature.indexOf(' ') + 1),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
