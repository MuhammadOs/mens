import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mens/shared/widgets/staggered_slide_fade.dart';
import 'package:mens/features/seller/Products/domain/product.dart';

class ProductInfoSection extends HookWidget {
  final Product product;
  final ThemeData theme;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // State for expandable description
    final isExpanded = useState(false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      transform: Matrix4.translationValues(0, -20, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store & Rating Row
            _buildStoreTag(context),
            const SizedBox(height: 16),

            // Title & Price
            StaggeredSlideFade(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStockIndicator(context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoChips(context),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Divider(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),

            // Description with Read More
            StaggeredSlideFade(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedCrossFade(
                    firstChild: Text(
                      product.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.6,
                      ),
                    ),
                    secondChild: Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.6,
                      ),
                    ),
                    crossFadeState: isExpanded.value
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (product.description.length >
                      150) // Arbitrary length check
                    TextButton(
                      onPressed: () => isExpanded.value = !isExpanded.value,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isExpanded.value ? "Read Less" : "Read More",
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 120), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStoreTag(BuildContext context) {
    if (product.storeName == null) return const SizedBox.shrink();

    return StaggeredSlideFade(
      index: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              product.storeName!.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(BuildContext context) {
    final stock = product.stockQuantity;
    final isInStock = stock > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isInStock ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isInStock ? 'In Stock ($stock)' : 'Out of Stock ($stock)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isInStock ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips(BuildContext context) {
    if (product.categoryName.isEmpty && product.material == null) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];

    // Category / SubCategory Chip
    if (product.categoryName.isNotEmpty) {
      String catLabel = product.categoryName;
      if (product.subCategoryName.isNotEmpty) {
        catLabel += ' • ${product.subCategoryName}';
      }
      chips.add(_StyledChip(label: catLabel, icon: Icons.category_rounded));
    }

    // Material Chip
    if (product.material != null && product.material!.isNotEmpty) {
      chips.add(_StyledChip(label: product.material!, icon: Icons.texture));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}

class _StyledChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StyledChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
