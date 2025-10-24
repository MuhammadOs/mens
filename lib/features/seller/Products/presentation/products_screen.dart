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
import 'package:mens/shared/widgets/products_list_items.dart';
import 'package:mens/shared/widgets/products_list_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';

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
              ...subCategories.map((subCat) => Tab(text: subCat.name)),
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
          loading: () =>
              Skeletonizer(child: ProductListSkeleton()), // Skeleton for list
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
          ProductListItem(product: products[index]),
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
