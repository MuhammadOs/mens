import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/admin/presentation/notifiers/paginated_admin_products_notifier.dart';
import 'package:mens/shared/widgets/products_list_items.dart';
import 'package:mens/shared/widgets/products_list_skeleton.dart';
import 'package:mens/shared/widgets/pagination_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllProductsView extends ConsumerWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedState = ref.watch(paginatedAdminProductsProvider);
    final notifier = ref.read(paginatedAdminProductsProvider.notifier);

    // Load first page if not loaded yet
    if (!paginatedState.hasData &&
        !paginatedState.isLoading &&
        paginatedState.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.loadFirstPage();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("All Products")),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: _buildContent(context, paginatedState, notifier),
      ),
    );
  }

  Widget _buildContent(BuildContext context, paginatedState, notifier) {
    if (paginatedState.isLoading && !paginatedState.hasData) {
      return Skeletonizer(child: ProductListSkeleton());
    }

    if (paginatedState.error != null && !paginatedState.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${paginatedState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!paginatedState.hasData) {
      return const Center(child: Text('No products found'));
    }

    return Column(
      children: [
        // Products list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: paginatedState.allItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) =>
                ProductListItem(product: paginatedState.allItems[index]),
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
              compact: true,
            ),
          ),
      ],
    );
  }
}
