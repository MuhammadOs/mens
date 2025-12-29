import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/brands/domain/brand.dart';
import 'package:mens/features/user/brands/presentation/notifiers/paginated_brand_products_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/Products/presentation/product_details_screen.dart';
import 'package:mens/shared/providers/paginated_notifier.dart';
import 'package:mens/shared/widgets/sticky_header_delegate.dart';
import 'package:mens/shared/widgets/staggered_slide_fade.dart';
import 'package:skeletonizer/skeletonizer.dart';


class BrandDetailsScreen extends HookConsumerWidget {
  final Brand brand;

  const BrandDetailsScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final productsState = ref.watch(brandProductsProvider(brand.id));
    final notifier = ref.read(brandProductsProvider(brand.id).notifier);

    // Search controller for local filtering (future enhancement)
    // final searchController = useTextEditingController();
    final scrollController = useScrollController();

    // Initial load
    useEffect(() {
      Future.microtask(() {
        if (!productsState.hasData && !productsState.isLoading) {
           notifier.loadFirstPage();
        }
      });
      return null;
    }, [brand.id]);

    // Infinite Scroll Listener
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        if (currentScroll >= (maxScroll - 200) && productsState.canLoadMore) {
          notifier.loadNextPage();
        }
      }
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, productsState.canLoadMore]);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async => notifier.refresh(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // 1. Enhanced Banner
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              stretch: true,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (brand.brandImage != null)
                      Image.network(brand.brandImage!, fit: BoxFit.cover)
                    else
                      Container(
                        decoration: BoxDecoration(
                           gradient: LinearGradient(
                              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                           ),
                        ),
                        child: Icon(Icons.store, size: 80, color: Colors.white.withOpacity(0.3)),
                      ),
                    // Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6), // Darker bottom for text contrast
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Profile Info (Overlapping)
            SliverToBoxAdapter(
               child: Transform.translate(
                 offset: const Offset(0, -30),
                 child: Container(
                   decoration: BoxDecoration(
                     color: theme.colorScheme.surface,
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                   ),
                   child: Column(
                     children: [
                       const SizedBox(height: 12),
                       // Handle Bar
                       Container(
                         width: 40, height: 4,
                         decoration: BoxDecoration(
                           color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                           borderRadius: BorderRadius.circular(2),
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(16.0),
                         child: Column(
                           children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    backgroundImage: brand.brandImage != null ? NetworkImage(brand.brandImage!) : null,
                                    child: brand.brandImage == null ? Text(brand.brandName[0].toUpperCase()) : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          brand.brandName,
                                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          brand.categoryName,
                                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Description or Owner
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.category_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${l10n.categoryLabel}: ${brand.categoryName}",
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
            ),

            // 3. Sticky Header for Products Title & Count
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                         l10n.brandProducts,
                         style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${productsState.currentPage?.totalCount ?? productsState.allItems.length} Items',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Products Grid
            _buildProductGrid(context, productsState, ref, l10n, theme),

            // 5. Loading More Indicator
            if (productsState.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  ),
                ),
              ),

             const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    BuildContext context,
    PaginatedState<Product> productsState,
    WidgetRef ref,
    dynamic l10n,
    ThemeData theme,
  ) {
    if (productsState.isLoading && productsState.allItems.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const _ProductCardSkeleton(),
            childCount: 6,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.70, // Slightly taller for better layout
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      );
    }

    if (productsState.error != null && productsState.allItems.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(l10n.errorPrefix + productsState.error.toString()),
              TextButton(
                onPressed: () => ref
                    .read(brandProductsProvider(brand.id).notifier)
                    .refresh(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (productsState.allItems.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = productsState.allItems[index];
          return StaggeredSlideFade(
            index: index,
            child: _EnhancedProductCard(product: product),
          );
        }, childCount: productsState.allItems.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65, // Taller aspect ratio for more "premium" look
          crossAxisSpacing: 10,
          mainAxisSpacing: 16,
        ),
      ),
    );
  }
}

// --- ENHANCED PRODUCT CARD ---

class _EnhancedProductCard extends StatelessWidget {
  final Product product;
  const _EnhancedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // ADDED: Navigation to Product Details Screen
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Wishlist Button
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.images.isNotEmpty)
                    Image.network(
                      product.images.first.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Text(
                    "Men's Wear", // Fallback or product.categoryName
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Skeletonizer(
      enabled: true,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(height: 12, width: 80, color: Colors.grey[300]), // title
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 16, width: 40, color: Colors.grey[300]), // price
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
                      ), // add button
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
