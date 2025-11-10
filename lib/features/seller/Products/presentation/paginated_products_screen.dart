import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/presentation/notifiers/paginated_products_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/features/seller/categories/domain/category.dart';
import 'package:mens/shared/widgets/products_list_items.dart';
import 'package:mens/shared/widgets/products_list_skeleton.dart';
// pagination_widget was removed in favor of infinite scroll
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/shared/providers/overlay_suppression_provider.dart';

class PaginatedProductsScreen extends HookConsumerWidget {
  const PaginatedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Suppress global loading overlay while this screen is visible
    useEffect(() {
      // Defer setting the suppression flag to avoid nested provider updates
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

    // Get Logged-in User's Category ID
    final userProfile = ref.watch(authNotifierProvider).asData?.value;
    final userCategoryId = userProfile?.store?.categoryId;

    // Fetch Subcategories for the User's Main Category
    final subCategoriesAsyncValue = userCategoryId != null
        ? ref.watch(subCategoriesProvider(userCategoryId))
        : const AsyncValue<List<SubCategory>>.loading();

    // Get paginated products state
    final paginatedState = ref.watch(paginatedProductsProvider);
    final notifier = ref.read(paginatedProductsProvider.notifier);

    // State for selected tab index
    final selectedTabIndex = useState(0);
    // Local flag to indicate category-change loading so we can show skeletons
    final categoryLoading = useState(false);
    // Scroll controller for infinite scroll (load more on scroll)
    final scrollController = useScrollController();

    // TabController (no implicit "All" tab)
    final tabController = useTabController(
      initialLength: subCategoriesAsyncValue.maybeWhen(
        data: (subCats) => subCats.isNotEmpty ? subCats.length : 1,
        orElse: () => 1,
      ),
      keys: [subCategoriesAsyncValue.asData?.value.length ?? 0],
    );

    // Handle tab changes and load filtered data
    useEffect(() {
      void listener() {
        if (!tabController.indexIsChanging &&
            selectedTabIndex.value != tabController.index) {
          selectedTabIndex.value = tabController.index;

          // Load products based on selected tab
          final subCategories = subCategoriesAsyncValue.asData?.value ?? [];
          if (subCategories.isEmpty) {
            // No subcategories: load all products
            categoryLoading.value = true;
            notifier.loadAll();
          } else {
            // Map selected tab index directly to subcategory index
            final selectedIndex = selectedTabIndex.value;
            if (selectedIndex >= 0 && selectedIndex < subCategories.length) {
              final selectedSubCatId = subCategories[selectedIndex].id;
              categoryLoading.value = true;
              notifier.loadBySubCategory(selectedSubCatId);
            }
          }
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController, subCategoriesAsyncValue]);

    // Attach scroll listener to implement infinite scroll
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final maxScroll = scrollController.position.maxScrollExtent;
        final current = scrollController.position.pixels;
        // Trigger load when within 200px of bottom
        if (current >= (maxScroll - 200)) {
          if (paginatedState.canLoadMore) {
            notifier.loadNextPage();
          } else {}
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, paginatedState]);

    // Load initial data when component mounts
    useEffect(() {
      if (!paginatedState.hasData &&
          !paginatedState.isLoading &&
          paginatedState.error == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.loadFirstPage();
        });
      }
      return null;
    }, []);

    // When provider finishes loading, clear the categoryLoading flag so UI
    // will stop showing skeletons. This listens specifically to the loading
    // state and clears our local flag when loading completes.
    useEffect(() {
      if (!paginatedState.isLoading) {
        categoryLoading.value = false;
      }
      return null;
    }, [paginatedState.isLoading]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.productsTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        elevation: 0,
        bottom: subCategoriesAsyncValue.maybeWhen(
          data: (subCategories) => TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: l10n.productsAll),
              ...subCategories.map((subCat) => Tab(text: subCat.name)),
            ],
          ),
          orElse: () => PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Skeletonizer(
              child: TabBar(
                isScrollable: true,
                controller: useTabController(initialLength: 1, keys: [0]),
                tabs: const [Tab(child: Bone.text(width: 60))],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: _buildBody(
          context,
          paginatedState,
          notifier,
          l10n,
          categoryLoading.value,
          scrollController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addProduct),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    paginatedState,
    notifier,
    l10n,
    bool categoryLoading,
    ScrollController scrollController,
  ) {
    if ((paginatedState.isLoading && !paginatedState.hasData) ||
        categoryLoading) {
      return Skeletonizer(child: ProductListSkeleton());
    }

    if (paginatedState.error != null && !paginatedState.hasData) {
      return _ErrorStateWithRefresh(
        error: paginatedState.error!,
        onRefresh: () => notifier.refresh(),
        l10n: l10n,
      );
    }

    if (!paginatedState.hasData) {
      return _buildEmptyState(context, l10n);
    }

    return Column(
      children: [
        // Products list
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                paginatedState.allItems.length +
                (paginatedState.isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= paginatedState.allItems.length) {
                // Loading more skeleton row
                return Skeletonizer(
                  enabled: true,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
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
                            width: 64,
                            height: 64,
                            child: Container(
                              width: 64,
                              height: 64,
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [Bone.icon()],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ProductListItem(product: paginatedState.allItems[index]);
            },
          ),
        ),

        // (infinite scroll implemented via ScrollController) -- keep a small
        // bottom padding to avoid content being obscured by FAB.
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, l10n) {
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
}

class _ErrorStateWithRefresh extends StatelessWidget {
  const _ErrorStateWithRefresh({
    required this.error,
    required this.onRefresh,
    required this.l10n,
  });

  final String error;
  final VoidCallback onRefresh;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.errorLoading}: $error',
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onRefresh,
                      child: Text(l10n.pullDownToRefresh),
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
