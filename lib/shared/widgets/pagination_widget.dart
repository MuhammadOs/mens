import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/shared/models/paginated_response.dart';

/// A reusable pagination widget that displays pagination controls
class PaginationWidget extends ConsumerWidget {
  final PaginatedResponse paginatedData;
  final Function(int page) onPageChanged;
  final bool showItemsInfo;
  final bool compact;

  const PaginationWidget({
    super.key,
    required this.paginatedData,
    required this.onPageChanged,
    this.showItemsInfo = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    if (compact) {
      return _buildCompactPagination(theme, l10n);
    }

    return _buildFullPagination(theme, l10n);
  }

  Widget _buildCompactPagination(ThemeData theme, dynamic l10n) {
    return Container(
      height: 48, // Smaller height
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            onPressed: (paginatedData.page > 1)
                ? () => onPageChanged(paginatedData.page - 1)
                : null,
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            tooltip: l10n.previousPage,
          ),

          // Simple pagination: Prev | Current | Next
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous page number (if exists)
              if (paginatedData.page > 1)
                TextButton(
                  onPressed: () => onPageChanged(paginatedData.page - 1),
                  child: Text('${paginatedData.page - 1}'),
                ),

              // Current page (highlighted)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${paginatedData.page}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Next page number (if exists)
              if (paginatedData.page < paginatedData.totalPages)
                TextButton(
                  onPressed: () => onPageChanged(paginatedData.page + 1),
                  child: Text('${paginatedData.page + 1}'),
                ),
            ],
          ),

          // Next button
          IconButton(
            onPressed: (paginatedData.page < paginatedData.totalPages)
                ? () => onPageChanged(paginatedData.page + 1)
                : null,
            icon: const Icon(FontAwesomeIcons.chevronRight),
            tooltip: l10n.nextPage,
          ),
        ],
      ),
    );
  }

  Widget _buildFullPagination(ThemeData theme, dynamic l10n) {
    return Container(
      height: 60, // Smaller height for full pagination
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Items summary (smaller text)
          if (showItemsInfo)
            Text(
              l10n.itemsRange(
                (paginatedData.page - 1) * paginatedData.pageSize +
                    1, // startItem
                ((paginatedData.page * paginatedData.pageSize) >
                        paginatedData.totalCount)
                    ? paginatedData.totalCount
                    : (paginatedData.page * paginatedData.pageSize), // endItem
                paginatedData.totalCount,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),

          const SizedBox(height: 4),

          // Simplified pagination controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              IconButton(
                onPressed: (paginatedData.page > 1)
                    ? () => onPageChanged(paginatedData.page - 1)
                    : null,
                icon: const Icon(FontAwesomeIcons.chevronLeft),
                tooltip: l10n.previousPage,
                iconSize: 20,
              ),

              // Simple pagination: Prev | Current | Next
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous page number (if exists)
                  if (paginatedData.page > 1)
                    TextButton(
                      onPressed: () => onPageChanged(paginatedData.page - 1),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: const EdgeInsets.all(4),
                      ),
                      child: Text(
                        '${paginatedData.page - 1}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),

                  // Current page (highlighted)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${paginatedData.page}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Next page number (if exists)
                  if (paginatedData.page < paginatedData.totalPages)
                    TextButton(
                      onPressed: () => onPageChanged(paginatedData.page + 1),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: const EdgeInsets.all(4),
                      ),
                      child: Text(
                        '${paginatedData.page + 1}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),

              // Next button
              IconButton(
                onPressed: (paginatedData.page < paginatedData.totalPages)
                    ? () => onPageChanged(paginatedData.page + 1)
                    : null,
                icon: const Icon(FontAwesomeIcons.chevronRight),
                tooltip: l10n.nextPage,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
