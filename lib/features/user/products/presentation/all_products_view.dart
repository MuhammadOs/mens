import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/products/presentation/buyer_product_card_skeletonizer.dart';
import 'package:mens/features/user/products/presentation/notifiers/paginated_user_products_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/features/user/products/presentation/product_card.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';
import 'package:mens/shared/widgets/pagination_widget.dart';

class AllProductsView extends HookConsumerWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final paginatedState = ref.watch(paginatedUserProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    // State
    final selectedCategoryId = useState<int?>(null);
    final selectedSubCategoryId = useState<int?>(null);
    final searchController = useTextEditingController();
    final searchDebounce = useRef<Timer?>(null);

    // Initial Load
    useEffect(() {
      Future.microtask(
        () => ref.read(paginatedUserProductsProvider.notifier).loadFirstPage(),
      );
      return null;
    }, []);

    // Search Logic with Debounce
    void onSearchChanged(String query) {
      if (searchDebounce.value?.isActive ?? false) {
        searchDebounce.value!.cancel();
      }
      searchDebounce.value = Timer(const Duration(milliseconds: 500), () {
        ref
            .read(paginatedUserProductsProvider.notifier)
            .setFilters(
              categoryId: selectedCategoryId.value,
              subCategoryId: selectedSubCategoryId.value,
            );
      });
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 1. Fixed Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SearchBar(
              controller: searchController,
              hintText: l10n.searchHint,
              elevation: WidgetStateProperty.all(0),
              leading: const Icon(FontAwesomeIcons.magnifyingGlass),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
              hintStyle: WidgetStateProperty.all(
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withAlpha(50),
                  ),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // 2. Fixed Category Filters
          categoriesAsync.when(
            data: (categories) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Categories
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _FilterChip(
                          label: l10n.productsAll,
                          isSelected: selectedCategoryId.value == null,
                          onSelected: (_) {
                            selectedCategoryId.value = null;
                            selectedSubCategoryId.value = null;
                            ref
                                .read(paginatedUserProductsProvider.notifier)
                                .setFilters(
                                  categoryId: null,
                                  subCategoryId: null,
                                );
                          },
                        );
                      }
                      final category = categories[index - 1];
                      return _FilterChip(
                        label: category.name,
                        isSelected: selectedCategoryId.value == category.id,
                        onSelected: (selected) {
                          if (selected) {
                            selectedCategoryId.value = category.id;
                            selectedSubCategoryId.value = null;
                            ref
                                .read(paginatedUserProductsProvider.notifier)
                                .setFilters(
                                  categoryId: category.id,
                                  subCategoryId: null,
                                );
                          }
                        },
                      );
                    },
                  ),
                ),

                // Sub Categories (Animated visibility could be added here)
                if (selectedCategoryId.value != null) ...[
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final selectedCategory = categories.firstWhere(
                        (cat) => cat.id == selectedCategoryId.value,
                      );
                      if (selectedCategory.subCategories.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: selectedCategory.subCategories.length,
                          itemBuilder: (context, index) {
                            final sub = selectedCategory.subCategories[index];
                            return _FilterChip(
                              label: sub.name,
                              isSmall: true,
                              isSelected: selectedSubCategoryId.value == sub.id,
                              onSelected: (selected) {
                                selectedSubCategoryId.value = selected
                                    ? sub.id
                                    : null;
                                ref
                                    .read(
                                      paginatedUserProductsProvider.notifier,
                                    )
                                    .setFilters(
                                      categoryId: selectedCategoryId.value,
                                      subCategoryId:
                                          selectedSubCategoryId.value,
                                    );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 3. Scrollable Product Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(paginatedUserProductsProvider.notifier).refresh();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildProductGrid(theme, l10n, paginatedState, ref),

                  // Pagination
                  if (paginatedState.currentPage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: PaginationWidget(
                          paginatedData: paginatedState.currentPage!,
                          onPageChanged: (page) {
                            ref
                                .read(paginatedUserProductsProvider.notifier)
                                .loadPage(page);
                          },
                          compact: true,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    ThemeData theme,
    dynamic l10n, // Type depends on your gen_l10n
    PaginatedState<Product> state,
    WidgetRef ref,
  ) {
    // Loading State
    if (state.isLoading && state.allItems.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const BuyerProductCardSkeleton(),
            childCount: 6,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Changed from 2 to 3
            childAspectRatio: 0.6, // Adjusted ratio for 3 columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      );
    }

    // Error State
    if (state.error != null && state.allItems.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.cloud,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(l10n.somethingWentWrong),
              TextButton(
                onPressed: () =>
                    ref.read(paginatedUserProductsProvider.notifier).refresh(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Empty State
    if (state.allItems.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.magnifyingGlass,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(l10n.noProductsFound, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    // Content State
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = state.allItems[index];
          return BuyerProductCard(product: product);
        }, childCount: state.allItems.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Changed from 2 to 3
          childAspectRatio: 0.6, // Adjusted ratio for 3 columns
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final bool isSmall;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        fontSize: isSmall ? 12 : 14,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: isSmall
          ? const EdgeInsets.symmetric(horizontal: 8)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
