import 'package:flutter/material.dart';
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
import 'package:mens/shared/widgets/pagination_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PaginatedProductsScreen extends HookConsumerWidget {
  const PaginatedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // TabController
    final tabController = useTabController(
      initialLength: subCategoriesAsyncValue.maybeWhen(
        data: (subCats) => subCats.length + 1,
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
          if (selectedTabIndex.value == 0) {
            // "All" tab
            notifier.loadAll();
          } else {
            // Specific subcategory tab
            final selectedSubCategoryIndex = selectedTabIndex.value - 1;
            if (selectedSubCategoryIndex >= 0 &&
                selectedSubCategoryIndex < subCategories.length) {
              final selectedSubCatId =
                  subCategories[selectedSubCategoryIndex].id;
              notifier.loadBySubCategory(selectedSubCatId);
            }
          }
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController, subCategoriesAsyncValue]);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        bottom: subCategoriesAsyncValue.maybeWhen(
          data: (subCategories) => TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: l10n.productsAll),
              ...subCategories.map((subCat) => Tab(text: subCat.name)).toList(),
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
        child: _buildBody(context, paginatedState, notifier, l10n),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addProduct),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, paginatedState, notifier, l10n) {
    if (paginatedState.isLoading && !paginatedState.hasData) {
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
            padding: const EdgeInsets.all(16),
            itemCount:
                paginatedState.allItems.length +
                (paginatedState.isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= paginatedState.allItems.length) {
                // Loading more indicator
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(l10n.loadingMore),
                      ],
                    ),
                  ),
                );
              }
              return ProductListItem(product: paginatedState.allItems[index]);
            },
          ),
        ),

        // Pagination controls
        if (paginatedState.currentPage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: PaginationWidget(
              paginatedData: paginatedState.currentPage!,
              onPageChanged: (page) => notifier.loadPage(page),
              compact: true, // Use compact mode to save space
            ),
          ),
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
