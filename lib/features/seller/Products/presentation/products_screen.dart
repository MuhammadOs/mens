import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:mens/shared/providers/overlay_suppression_provider.dart';

class ProductsScreen extends HookConsumerWidget {
  // Use HookConsumerWidget
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Suppress global loading overlay while this screen is visible
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(overlaySuppressionProvider.notifier).setSuppressed(true);
      });
      return () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(overlaySuppressionProvider.notifier).setSuppressed(false);
        });
      };
    }, const []);

    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

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

    // TabController - Length depends on fetched subcategories (no 'All' tab)
    // Use a key to rebuild if the number of tabs changes
    final tabController = useTabController(
      initialLength: subCategoriesAsyncValue.maybeWhen(
        data: (subCats) => subCats.isNotEmpty ? subCats.length : 1,
        orElse: () => 1,
      ),
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
          data: (subCategories) {
            // If there are no subcategories, don't show tabs
            if (subCategories.isEmpty) {
              return const PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: SizedBox.shrink(),
              );
            }
            return TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.primary,
              indicatorColor: theme.colorScheme.primary,
              tabs: [...subCategories.map((subCat) => Tab(text: subCat.name))],
            );
          },
          // Show a minimal placeholder TabBar during loading/error
          orElse: () => PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Skeletonizer(
              // Skeleton for tabs
              child: TabBar(
                isScrollable: true,
                controller: useTabController(initialLength: 3, keys: [0]),
                tabs: const [
                  Tab(child: Bone.text(width: 60)),
                  Tab(child: Bone.text(width: 60)),
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

            // --- LOCAL FILTERING (No 'All' tab) ---
            final List<Product> filteredProducts;
            if (subCategories.isEmpty) {
              // No subcategories available: show all products
              filteredProducts = allProducts;
            } else {
              final selectedIndex = selectedTabIndex.value;
              if (selectedIndex >= 0 && selectedIndex < subCategories.length) {
                final selectedSubCatId = subCategories[selectedIndex].id;
                filteredProducts = allProducts
                    .where((p) => p.subCategoryId == selectedSubCatId)
                    .toList();
              } else {
                // Fallback to all products if index is out of range
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
        child: const Icon(FontAwesomeIcons.plus),
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
                      FontAwesomeIcons.circleExclamation,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.somethingWentWrong,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pullDownToRefresh,
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
