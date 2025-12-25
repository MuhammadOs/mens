import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/brands/domain/brand.dart';
import 'package:mens/features/user/brands/presentation/brand_details_screen.dart';
import 'package:mens/features/user/brands/presentation/notifiers/paginated_brands_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';
import 'package:mens/shared/widgets/pagination_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllBrandsView extends HookConsumerWidget {
  const AllBrandsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final brandState = ref.watch(paginatedBrandsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    // State
    final selectedCategoryId = useState<int?>(null);
    final searchController = useTextEditingController();
    // Optional: Add debounce if your API supports search text for brands
    // final searchDebounce = useRef<Timer?>(null);

    // Initial Load
    useEffect(() {
      Future.microtask(
        () => ref.read(paginatedBrandsProvider.notifier).loadFirstPage(),
      );
      return null;
    }, []);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.allBrandsTitle),
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
              leading: Icon(
                FontAwesomeIcons.magnifyingGlass,
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
              onChanged: (query) {
                // Implement search logic here if needed
              },
            ),
          ),

          // 2. Fixed Category Filters
          categoriesAsync.when(
            data: (categories) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _CategoryChip(
                          label: l10n.allCategories,
                          isSelected: selectedCategoryId.value == null,
                          onSelected: (_) {
                            selectedCategoryId.value = null;
                            ref
                                .read(paginatedBrandsProvider.notifier)
                                .setFilters(categoryId: null);
                          },
                        );
                      }
                      final category = categories[index - 1];
                      return _CategoryChip(
                        label: category.name,
                        isSelected: selectedCategoryId.value == category.id,
                        onSelected: (selected) {
                          if (selected) {
                            selectedCategoryId.value = category.id;
                            ref
                                .read(paginatedBrandsProvider.notifier)
                                .setFilters(categoryId: category.id);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 3. Scrollable Brands Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(paginatedBrandsProvider.notifier).refresh();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildBrandsGrid(theme, l10n, brandState, ref),

                  // Pagination
                  if (brandState.currentPage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: PaginationWidget(
                          paginatedData: brandState.currentPage!,
                          onPageChanged: (page) {
                            ref
                                .read(paginatedBrandsProvider.notifier)
                                .loadPage(page);
                          },
                          compact: true,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsGrid(
    ThemeData theme,
    dynamic l10n,
    PaginatedState<Brand> brandState,
    WidgetRef ref,
  ) {
    // Loading State
    if (brandState.isLoading && brandState.allItems.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const _BrandCardSkeleton(),
            childCount: 12,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      );
    }

    // Error State
    if (brandState.error != null && brandState.allItems.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.circleExclamation,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('${l10n.errorPrefix}${brandState.error}'),
              TextButton(
                onPressed: () =>
                    ref.read(paginatedBrandsProvider.notifier).loadFirstPage(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Empty State
    if (brandState.allItems.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.store,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noBrandsFound,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
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
          final brand = brandState.allItems[index];
          return _EnhancedBrandCard(brand: brand);
        }, childCount: brandState.allItems.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
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
        fontSize: 13,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _EnhancedBrandCard extends StatelessWidget {
  final Brand brand;
  const _EnhancedBrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BrandDetailsScreen(brand: brand)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Matches Product Card Surface
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(
              0.1,
            ), // Subtle border like products
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo with Hero Animation
            Hero(
              tag: 'brand_${brand.id}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: brand.brandImage != null
                      ? NetworkImage(brand.brandImage!)
                      : null,
                  child: brand.brandImage == null
                      ? Icon(
                          FontAwesomeIcons.store,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Brand Name
            Text(
              brand.brandName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Category Name
            Text(
              brand.categoryName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandCardSkeleton extends StatelessWidget {
  const _BrandCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Skeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Bone.circle(size: 56),
            const SizedBox(height: 10),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
