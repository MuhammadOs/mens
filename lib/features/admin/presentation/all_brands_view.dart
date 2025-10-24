import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/admin/brands/domain/brand.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_brands_notifier.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/widgets/pagination_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllBrandsView extends HookConsumerWidget {
  const AllBrandsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
      appBar: AppBar(
        title: const Text("All Brands/Sellers"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go(AppRoutes.adminProducts);
            },
            icon: const Icon(Icons.inventory_2),
            label: const Text("Products"),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              context.go(AppRoutes.adminConversations);
            },
            icon: const Icon(Icons.chat),
            label: const Text("Conversations"),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
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
            data: (categories) => Container(
              height: 50,
              margin: const EdgeInsets.only(left: 16, bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: const Text(
                          'All',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: selectedCategoryId.value == null
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selectedCategoryId.value == category.id
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
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
                          'Error: ${brandState.error}',
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
                          child: const Text('Retry'),
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
                            childAspectRatio: 0.85,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, index) =>
                          const _BrandCardSkeleton(),
                    ),
                  )
                : brandState.allItems.isEmpty
                ? const Center(child: Text("No brands found"))
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
                            childAspectRatio: 0.85,
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Brand Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: brand.brandImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        brand.brandImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.store,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.store,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
          ),

          // Brand Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              brand.brandName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _BrandCardSkeleton extends StatelessWidget {
  const _BrandCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Bone.square(size: 100),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Bone.text(words: 2),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
