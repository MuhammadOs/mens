import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:skeletonizer/skeletonizer.dart';

class PaginatedProductsScreen extends HookConsumerWidget {
  const PaginatedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final notifier = ref.read(paginatedProductsProvider.notifier);
    final paginatedState = ref.watch(paginatedProductsProvider);

    final userProfile = ref.watch(authNotifierProvider).asData?.value;
    final userCategoryId = userProfile?.store?.categoryId;

    final subCategoriesAsyncValue = userCategoryId != null
        ? ref.watch(subCategoriesProvider(userCategoryId))
        : const AsyncValue<List<SubCategory>>.loading();

    final selectedTabIndex = useState(0);

    final tabController = useTabController(
      initialLength: subCategoriesAsyncValue.maybeWhen(
        data: (subCats) => subCats.length + 1,
        orElse: () => 1,
      ),
      keys: [subCategoriesAsyncValue.asData?.value.length ?? 0],
    );

    final scrollController = useScrollController();

    // Load next page when scrolling near bottom
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final max = scrollController.position.maxScrollExtent;
        final pos = scrollController.position.pixels;
        if (pos >= (max - 200) && paginatedState.canLoadMore) {
          notifier.loadNextPage();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, paginatedState.canLoadMore]);

    // Handle tab switching
    useEffect(() {
      void listener() {
        if (!tabController.indexIsChanging &&
            selectedTabIndex.value != tabController.index) {
          selectedTabIndex.value = tabController.index;

          final subCategories = subCategoriesAsyncValue.asData?.value ?? [];
          if (selectedTabIndex.value == 0) {
            notifier.loadAll();
          } else {
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

    // Initial load
    useEffect(() {
      // 1. We must wait until we have the user's category ID
      if (userCategoryId != null) {
        // 2. Tell the notifier what the main category is
        // This is the new, critical line.
        notifier.setMainCategory(userCategoryId);

        // 3. Load the initial "All" page
        // Only load if we haven't loaded before
        if (!paginatedState.hasData &&
            !paginatedState.isLoading &&
            paginatedState.error == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifier.loadAll();
          });
        }
      }
      return null;
    }, [userCategoryId]);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        bottom: subCategoriesAsyncValue.maybeWhen(
          data: (subCategories) => TabBar(
            controller: tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.productsAll),
              ...subCategories.map((s) => Tab(text: s.name)),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
          ),
          orElse: () => PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Skeletonizer(
              child: TabBar(
                controller: useTabController(initialLength: 1, keys: [0]),
                isScrollable: true,
                tabs: const [Tab(child: Bone.text(width: 60))],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => notifier.refresh(),
        child: _buildBody(
          context,
          l10n,
          paginatedState,
          notifier,
          scrollController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addProduct),
        child: const Icon(FontAwesomeIcons.plus),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    l10n,
    state,
    notifier,
    ScrollController scrollController,
  ) {
    // --- THIS IS THE KEY CHANGE ---
    // Show a skeleton if we are in *any* loading state,
    // not just the initial one. This ensures that
    // switching tabs also shows the skeleton.
    if (state.isLoading) {
      return Skeletonizer(child: ProductListSkeleton());
    }
    // --- END OF CHANGE ---

    if (state.error != null && !state.hasData) {
      return _ErrorStateWithRefresh(
        error: state.error.toString(),
        onRefresh: () => notifier.refresh(),
        l10n: l10n,
      );
    }

    if (state.allItems.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.allItems.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index >= state.allItems.length) {
          return const Skeletonizer(child: _ProductListItemSkeleton());
        }
        return ProductListItem(product: state.allItems[index]);
      },
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
                      FontAwesomeIcons.circleExclamation,
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

class _ProductListItemSkeleton extends StatelessWidget {
  const _ProductListItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero, // The separatorBuilder handles spacing
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image placeholder
            Bone(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            SizedBox(width: 16),
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(width: 150),
                  SizedBox(height: 8),
                  Bone.text(width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
