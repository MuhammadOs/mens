import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // Import flutter_hooks
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart'; // Adjust path if needed
import 'package:mens/core/routing/app_router.dart'; // Adjust path if needed
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/features/seller/categories/domain/category.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart'; // Import AppLocalizations (Adjust path)

class ProductsScreen extends HookConsumerWidget {
  // Use HookConsumerWidget
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    // 1. Get Logged-in User's Category ID
    final userProfile = ref.watch(authNotifierProvider).asData?.value;
    final userCategoryId = userProfile?.store?.categoryId;

    // 2. Fetch Subcategories for the User's Main Category
    // Handle the case where userCategoryId might be null initially
    final subCategoriesAsyncValue = userCategoryId != null
        ? ref.watch(subCategoriesProvider(userCategoryId))
        : const AsyncValue<
            List<SubCategory>
          >.loading(); // Default to loading if no ID

    // Fetch all products once
    final allProductsAsyncValue = ref.watch(productsProvider);

    // State for selected tab index
    final selectedTabIndex = useState(0);

    // TabController - Length depends on fetched subcategories + "All"
    // Use a key to rebuild if the number of tabs changes
    final tabController = useTabController(
      initialLength: subCategoriesAsyncValue.maybeWhen(
        data: (subCats) => subCats.length + 1, // +1 for "All"
        orElse: () => 1, // Default to 1 tab ("All") during loading/error
      ),
      // Use the length of subcategories as a key to force rebuild
      keys: [subCategoriesAsyncValue.asData?.value.length ?? 0],
    );

    // Update state when tab changes
    useEffect(() {
      void listener() {
        if (!tabController.indexIsChanging &&
            selectedTabIndex.value != tabController.index) {
          selectedTabIndex.value = tabController.index;
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        // Build TabBar dynamically based on fetched subcategories
        bottom: subCategoriesAsyncValue.maybeWhen(
          data: (subCategories) => TabBar(
            controller: tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.productsAll), // "All" tab first
              // Dynamically create tabs for each subcategory
              ...subCategories.map((subCat) => Tab(text: subCat.name)).toList(),
            ],
          ),
          // Show a minimal placeholder TabBar during loading/error
          orElse: () => PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Skeletonizer(
              // Skeleton for tabs
              child: TabBar(
                isScrollable: true,
                // Need a dummy controller if main one isn't ready
                controller: useTabController(initialLength: 1, keys: [0]),
                tabs: const [
                  Tab(child: Bone.text(width: 60)),
                ], // Minimal placeholder
              ),
            ),
          ),
        ),
      ),
      // Wrap body content with RefreshIndicator
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate providers to trigger a refetch
          ref.invalidate(productsProvider);
          if (userCategoryId != null) {
            ref.invalidate(subCategoriesProvider(userCategoryId));
          }
          // Keep showing the indicator until the data is reloaded
          await ref.read(productsProvider.future);
        },
        // Combine loading/error states of products and subcategories
        child: allProductsAsyncValue.when(
          data: (allProducts) {
            // Use subcategories from the already watched provider
            final subCategories = subCategoriesAsyncValue.asData?.value ?? [];

            // --- LOCAL FILTERING (Now Dynamic) ---
            final List<Product> filteredProducts;
            if (selectedTabIndex.value == 0) {
              // "All" tab
              filteredProducts = allProducts;
            } else {
              // Get the SubCategory corresponding to the selected tab index (index - 1)
              final selectedSubCategoryIndex = selectedTabIndex.value - 1;
              if (selectedSubCategoryIndex >= 0 &&
                  selectedSubCategoryIndex < subCategories.length) {
                final selectedSubCatId =
                    subCategories[selectedSubCategoryIndex].id;
                filteredProducts = allProducts
                    .where((p) => p.subCategoryId == selectedSubCatId)
                    .toList();
              } else {
                // Fallback (shouldn't happen if TabController length is correct)
                filteredProducts = allProducts;
              }
            }
            // --- END LOCAL FILTERING ---

            // Display the filtered list
            return _ProductList(products: filteredProducts);
          },
          loading: () => const Skeletonizer(
            child: _ProductListSkeleton(),
          ), // Skeleton for list
          error: (error, stack) => _ErrorStateWithRefresh(
            error: error,
          ), // Error display with refresh hint
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addProduct),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Reusable Product List Widget ---
// Displays the list or an empty state message, ensuring scrollability for RefreshIndicator.
class _ProductList extends ConsumerWidget {
  const _ProductList({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    if (products.isEmpty) {
      // Make empty state scrollable for RefreshIndicator
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.noProductsInCategory,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // The ListView needs to be scrollable for RefreshIndicator
    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(), // Ensure scrolling is always possible
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _ProductListItem(product: products[index]),
    );
  }
}

// --- Skeleton Placeholder for Loading State ---
// Made scrollable to work correctly within RefreshIndicator.
class _ProductListSkeleton extends StatelessWidget {
  const _ProductListSkeleton();

  @override
  Widget build(BuildContext context) {
    // Wrap ListView in SingleChildScrollView to make it work with RefreshIndicator
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ListView.separated(
        shrinkWrap: true, // Important when nested in another scroll view
        physics:
            const NeverScrollableScrollPhysics(), // Prevent nested scrolling
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Show a few skeleton items
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => Bone(
          // Use Bone directly for card shape
          height: 104, // Match approx height of _ProductListItem
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// --- Error State Widget ---
// Extracted for clarity and ensures scrollability for RefreshIndicator.
class _ErrorStateWithRefresh extends StatelessWidget {
  const _ErrorStateWithRefresh({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use AppLocalizations.of here as it's a StatelessWidget
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Make error state scrollable
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // Use Column for icon + text
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.errorLoading}: $error', // TODO: Add localization key 'errorLoading'
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pullDownToRefresh, // TODO: Add localization key 'pullDownToRefresh'
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Individual Product List Item Widget ---
// Displays a single product's details.
class _ProductListItem extends HookConsumerWidget {
  const _ProductListItem({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Use AppLocalizations.of here as it's a StatelessWidget
    final l10n = AppLocalizations.of(context)!;
    
    // Local state for tracking delete loading status
    final isLoading = useState(false);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ // Optional: Add a subtle shadow
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ]
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // Display the first image URL from the product data
            child: product.firstImageUrl != null
                ? Image.network(
                    product.firstImageUrl!,
                    height: 80, width: 80, fit: BoxFit.cover,
                    // Handle image loading errors
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80, width: 80, color: Colors.grey[300],
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  )
                : Container( // Placeholder if no image URL
                    height: 80, width: 80, color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.storeName ?? l10n.storeNamePlaceholder, // TODO: Add l10n.storeNamePlaceholder
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
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
            mainAxisSize: MainAxisSize.min, // Prevent column from taking max height
            children: [
              IconButton(
                onPressed: () {
                   // Navigate to Edit Product Screen, passing product ID
                   // Ensure your AppRoutes.editProduct path is defined as '/products/:id/edit'
                   context.push('/products/${product.id}/edit');
                },
                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 20),
                tooltip: l10n.edit, // TODO: Add l10n.edit
              ),
              // Show loading spinner *instead of* the delete icon while deleting
              isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      // Apply padding to match IconButton's tap target size (approx)
                      child: Padding(
                        padding: EdgeInsets.all(14.0), // Adjust padding as needed
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
                      tooltip: l10n.delete, // TODO: Add l10n.delete
                      onPressed: () async {
                        // 1. Show confirmation dialog
                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: Text(l10n.delete), // TODO: Add l10n.delete and "Delete Product?"
                            content: Text("Are you sure you want to delete '${product.name}'?"), // TODO: Localize
                            actions: [
                              TextButton(
                                child: Text("Cancel"), // TODO: Localize
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                                child: Text(l10n.delete),
                                onPressed: () => Navigator.of(dialogContext).pop(true),
                              ),
                            ],
                          ),
                        );

                        // 2. If user confirmed, proceed with deletion
                        if (confirmed == true) {
                          isLoading.value = true; // Show loading spinner
                          try {
                            // 3. Call the repository method
                            await ref.read(productRepositoryProvider).deleteProduct(product.id);
                            
                            // 4. Success: Invalidate provider to refresh list
                            ref.invalidate(productsProvider);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Product deleted"), backgroundColor: Colors.green), // TODO: Localize
                              );
                            }
                          } catch (e) {
                            // 5. Error: Show error message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e"), backgroundColor: theme.colorScheme.error), // TODO: Localize
                              );
                            }
                            isLoading.value = false; // Hide loading spinner on error
                          }
                          // No need to set isLoading.value = false on success, as the widget will be removed by the refresh
                        }
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
