import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/categories/data/category_repository.dart';
import 'package:mens/shared/widgets/pagination_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllProductsView extends HookConsumerWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final paginatedState = ref.watch(paginatedAdminProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = useState<int?>(null);
    final selectedSubCategoryId = useState<int?>(null);

    useEffect(() {
      Future.microtask(
        () => ref.read(paginatedAdminProductsProvider.notifier).loadFirstPage(),
      );
      return null;
    }, []);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go(AppRoutes.adminBrands);
            },
            icon: const Icon(Icons.store),
            label: const Text("Brands"),
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

          // Category Filter
          categoriesAsync.when(
            data: (categories) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Categories
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 16, bottom: 8),
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
                                selectedSubCategoryId.value = null;
                                ref
                                    .read(
                                      paginatedAdminProductsProvider.notifier,
                                    )
                                    .setFilters(
                                      categoryId: null,
                                      subCategoryId: null,
                                    );
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
                              selectedSubCategoryId.value = null;
                              ref
                                  .read(paginatedAdminProductsProvider.notifier)
                                  .setFilters(
                                    categoryId: category.id,
                                    subCategoryId: null,
                                  );
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

                // Sub Categories (if category selected)
                if (selectedCategoryId.value != null)
                  Builder(
                    builder: (context) {
                      final selectedCategory = categories.firstWhere(
                        (cat) => cat.id == selectedCategoryId.value,
                      );

                      return Container(
                        height: 40,
                        margin: const EdgeInsets.only(left: 16, bottom: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedCategory.subCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory =
                                selectedCategory.subCategories[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(
                                  subCategory.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected:
                                    selectedSubCategoryId.value ==
                                    subCategory.id,
                                onSelected: (selected) {
                                  if (selected) {
                                    selectedSubCategoryId.value =
                                        subCategory.id;
                                  } else {
                                    selectedSubCategoryId.value = null;
                                  }
                                  ref
                                      .read(
                                        paginatedAdminProductsProvider.notifier,
                                      )
                                      .setFilters(
                                        categoryId: selectedCategoryId.value,
                                        subCategoryId:
                                            selectedSubCategoryId.value,
                                      );
                                },
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color:
                                      selectedSubCategoryId.value ==
                                          subCategory.id
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color:
                                        selectedSubCategoryId.value ==
                                            subCategory.id
                                        ? theme.colorScheme.primary.withOpacity(
                                            0.5,
                                          )
                                        : theme.colorScheme.outline.withOpacity(
                                            0.3,
                                          ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),

          // Products Grid
          Expanded(
            child:
                paginatedState.error != null && paginatedState.allItems.isEmpty
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
                          'Error: ${paginatedState.error}',
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(paginatedAdminProductsProvider.notifier)
                                .loadFirstPage();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : paginatedState.isLoading && paginatedState.allItems.isEmpty
                ? Skeletonizer(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) =>
                          const _ProductCardSkeleton(),
                    ),
                  )
                : paginatedState.allItems.isEmpty
                ? const Center(child: Text("No products found"))
                : RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(paginatedAdminProductsProvider.notifier)
                          .refresh();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: paginatedState.allItems.length,
                      itemBuilder: (context, index) {
                        final product = paginatedState.allItems[index];
                        return _ProductCard(product: product);
                      },
                    ),
                  ),
          ),

          // Pagination Widget
          if (paginatedState.currentPage != null)
            PaginationWidget(
              paginatedData: paginatedState.currentPage!,
              onPageChanged: (page) {
                ref
                    .read(paginatedAdminProductsProvider.notifier)
                    .loadPage(page);
              },
              compact: true,
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: product.firstImageUrl != null
                    ? Image.network(
                        product.firstImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                      ),
              ),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Bone.square(size: 100),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2),
                SizedBox(height: 4),
                Bone.text(words: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
