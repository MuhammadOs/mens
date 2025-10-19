import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart'; // Adjust path if needed

// Category IDs (Assuming these match your API for SubCategories)
// Adjust these IDs based on your actual API data if different
const int TOPS_CATEGORY_ID = 1;
const int BOTTOMS_CATEGORY_ID = 2; // Assuming 'Pants' is SubCategory ID 2
const int ACCESSORIES_CATEGORY_ID = 3;

class ProductsScreen extends HookConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    // Fetch all products once
    final allProductsAsyncValue = ref.watch(productsProvider);

    // State to track the currently selected tab index
    final selectedTabIndex = useState(0);

    // TabController synced with state
    final tabController = useTabController(initialLength: 4);

    // Update state when tab changes
    useEffect(() {
      void listener() {
        if (selectedTabIndex.value != tabController.index) {
          selectedTabIndex.value = tabController.index;
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener); // Cleanup listener
    }, [tabController]); // Dependency array

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        bottom: TabBar(
          controller: tabController, // Link controller to TabBar
          isScrollable: true, // Allows tabs to scroll if they don't fit
          tabs: [
            Tab(text: l10n.productsAll),
            Tab(text: l10n.productsTops),
            Tab(text: l10n.productsBottoms),
            Tab(text: l10n.productsAccessories),
          ],
        ),
      ),
      // Wrap the body content with RefreshIndicator
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate the provider to trigger a refetch
          ref.invalidate(productsProvider);
          // Keep showing the indicator until the data is reloaded
          await ref.read(productsProvider.future);
        },
        // The child of RefreshIndicator handles loading/error/data states
        child: allProductsAsyncValue.when(
          data: (allProducts) {
            // --- LOCAL FILTERING ---
            final List<Product> filteredProducts;
            switch (selectedTabIndex.value) {
              case 1: // Tops
                filteredProducts = allProducts
                    .where((p) => p.subCategoryId == TOPS_CATEGORY_ID)
                    .toList();
                break;
              case 2: // Bottoms (Pants)
                filteredProducts = allProducts
                    .where((p) => p.subCategoryId == BOTTOMS_CATEGORY_ID)
                    .toList();
                break;
              case 3: // Accessories
                filteredProducts = allProducts
                    .where((p) => p.subCategoryId == ACCESSORIES_CATEGORY_ID)
                    .toList();
                break;
              case 0: // All
              default:
                filteredProducts = allProducts; // Show all products
                break;
            }
            // --- END LOCAL FILTERING ---

            // Pass filtered products to the list widget
            return _ProductList(products: filteredProducts);
          },
          loading: () => const Skeletonizer(
            child: _ProductListSkeleton(),
          ), // Show skeleton
          error: (error, stack) => _ErrorStateWithRefresh(
            error: error,
          ), // Use helper for error state
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(AppRoutes.addProduct), // Navigate using push
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
                child: Text(
                  l10n.noProductsInCategory,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
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
    final l10n = AppLocalizations.of(context)!; // For localized text
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
                      '${l10n.errorLoading}: $error', // TODO: Add specific localization key
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pullDownToRefresh, // TODO: Add specific localization key
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
class _ProductListItem extends StatelessWidget {
  const _ProductListItem({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
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
            // Display the first image URL from the product data
            child: product.firstImageUrl != null
                ? Image.network(
                    product.firstImageUrl!,
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
                  product.storeName ??
                      l10n.storeNamePlaceholder, // TODO: Add localization key
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
                // Example:
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
                  // Navigate to edit screen, passing product ID
                  context.push('/products/${product.id}/edit');
                },
                icon: Icon(Icons.edit_outlined /* ... */),
              ),
              IconButton(
                onPressed: () {
                  /* TODO: Implement Delete Logic (show confirmation dialog) */
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                tooltip: l10n.delete, // TODO: Add localization key
              ),
            ],
          ),
        ],
      ),
    );
  }
}
