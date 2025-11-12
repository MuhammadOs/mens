import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/paginated_products_notifier.dart';
import 'package:mens/features/seller/Products/presentation/product_details_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductListItem extends HookConsumerWidget {
  const ProductListItem({
    super.key,
    required this.product,
    this.isLoading = false,
  });
  final Product product;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Use AppLocalizations.of here as it's a StatelessWidget
    final l10n = AppLocalizations.of(context)!;

    // Local state for tracking delete loading status
    // (rename to avoid clash with the `isLoading` parameter)
    final isDeleting = useState(false);

    // Show skeletonized row using `skeletonizer` when loading
    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Skeleton.replace(
                  width: 80,
                  height: 80,
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(),
                    const SizedBox(height: 8),
                    Bone.text(words: 2),
                    const SizedBox(height: 8),
                    Bone.text(words: 3),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [Bone.icon(), const SizedBox(height: 8), Bone.icon()],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsScreen(product: product, isAdmin: false),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Optional: Add a subtle shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Display the primary image URL from the product data
              child: product.primaryImageUrl != null
                  ? Image.network(
                      product.primaryImageUrl!,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      // Handle image loading errors
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      // Placeholder if no image URL
                      height: 80,
                      width: 80,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.subCategoryName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Format price properly
                  Text(
                    "\$${product.price.toStringAsFixed(2)}  •  ${l10n.stock}: ${product.stockQuantity}", // Use stockQuantity
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  // TODO: Add Rating and Sold count if available in your Product model
                  // Row(
                  //   children: [
                  //     Icon(Icons.star, color: Colors.amber, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text('${product.rating} (${product.sold} ${l10n.productSold})',
                  //       style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            // Action Buttons (Edit/Delete)
            Column(
              mainAxisSize:
                  MainAxisSize.min, // Prevent column from taking max height
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate to Edit Product Screen, passing product ID
                    // Ensure your AppRoutes.editProduct path is defined as '/products/:id/edit'
                    context.push('/products/${product.id}/edit');
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: l10n.edit, // TODO: Add l10n.edit
                ),
                // Show loading spinner *instead of* the delete icon while deleting
                isDeleting.value
                    ? const SizedBox(width: 20, height: 20)
                    : IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        tooltip: l10n.delete, // TODO: Add l10n.delete
                        onPressed: () async {
                          // 1. Show confirmation dialog
                          final bool? confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(
                                l10n.delete,
                              ), // TODO: Add l10n.delete and "Delete Product?"
                              content: Text(
                                "Are you sure you want to delete '${product.name}'?",
                              ), // TODO: Localize
                              actions: [
                                TextButton(
                                  child: Text(l10n.cancel),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                  child: Text(l10n.delete),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                ),
                              ],
                            ),
                          );

                          // 2. If user confirmed, proceed with deletion
                          if (confirmed == true) {
                            isDeleting.value = true; // Show loading spinner
                            try {
                              // 3. Call the repository method
                              await ref
                                  .read(productRepositoryProvider)
                                  .deleteProduct(product.id);

                              // 4. Success: Refresh providers to update all product lists
                              ref.invalidate(productsProvider);
                              ref
                                  .read(paginatedProductsProvider.notifier)
                                  .refresh();
                              ref
                                  .read(paginatedAdminProductsProvider.notifier)
                                  .refresh();

                              // SnackBar removed: productDeleted notification suppressed.
                            } catch (e) {
                              // 5. Error: Show generic error message
                              // SnackBar removed: errorDeletingProduct notification suppressed.
                            } finally {
                              // Always hide loading spinner after completion
                              isDeleting.value = false;
                            }
                          }
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}