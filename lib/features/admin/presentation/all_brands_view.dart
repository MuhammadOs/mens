import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/admin/brands/domain/brand.dart';
import 'package:mens/features/admin/presentation/admin_drawer.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_brands_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
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
    final selectedCategoryId = useState<int?>(null);

    useEffect(() {
      Future.microtask(
        () => ref.read(paginatedBrandsProvider.notifier).loadFirstPage(),
      );
      return null;
    }, []);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: Text(
          l10n.allBrandsTitle,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Filter Tabs
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          l10n.allCategories,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: selectedCategoryId.value == null
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        selected: selectedCategoryId.value == null,
                        onSelected: (selected) {
                          if (selected) {
                            selectedCategoryId.value = null;
                            ref
                                .read(paginatedBrandsProvider.notifier)
                                .setFilters(categoryId: null);
                          }
                        },
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        selectedColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    );
                  }

                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: selectedCategoryId.value == category.id
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      selected: selectedCategoryId.value == category.id,
                      onSelected: (selected) {
                        if (selected) {
                          selectedCategoryId.value = category.id;
                          ref
                              .read(paginatedBrandsProvider.notifier)
                              .setFilters(categoryId: category.id);
                        }
                      },
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      selectedColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),

          // Brands Grid
          Expanded(
            child: brandState.error != null && brandState.allItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${l10n.errorPrefix}${brandState.error}',
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(paginatedBrandsProvider.notifier)
                                .loadFirstPage();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  )
                : brandState.isLoading && brandState.allItems.isEmpty
                ? Skeletonizer(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) =>
                          const _BrandCardSkeleton(),
                    ),
                  )
                : brandState.allItems.isEmpty
                ? Center(
                    child: Text(
                      l10n.noBrandsFound,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.read(paginatedBrandsProvider.notifier).refresh();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: brandState.allItems.length,
                      itemBuilder: (context, index) {
                        final brand = brandState.allItems[index];
                        return _BrandCard(brand: brand);
                      },
                    ),
                  ),
          ),

          // Pagination Widget
          if (brandState.currentPage != null)
            PaginationWidget(
              paginatedData: brandState.currentPage!,
              onPageChanged: (page) {
                ref.read(paginatedBrandsProvider.notifier).loadPage(page);
              },
              compact: true,
            ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand});
  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Image - Circular
        Flexible(
          flex: 3,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: brand.brandImage != null
                ? ClipOval(
                    child: Image.network(
                      brand.brandImage!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.store,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
                : Icon(
                    Icons.store,
                    size: 32,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
          ),
        ),

        const SizedBox(height: 6),

        // Brand Name
        Flexible(
          flex: 2,
          child: Text(
            brand.brandName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 2),

        // Owner Name
        Text(
          brand.ownerName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 9,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 2),

        // Category
        Text(
          brand.categoryName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 9,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BrandCardSkeleton extends StatelessWidget {
  const _BrandCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular skeleton
        Flexible(flex: 3, child: Bone.circle(size: 70)),
        SizedBox(height: 6),
        // Brand name
        Flexible(flex: 2, child: Bone.text(words: 2)),
        SizedBox(height: 2),
        // Owner name
        Bone.text(words: 1),
        SizedBox(height: 2),
        // Category
        Bone.text(words: 1),
      ],
    );
  }
}
