import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/admin/admin_repository.dart';
import 'package:mens/shared/widgets/products_list_items.dart';
import 'package:mens/shared/widgets/products_list_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllProductsView extends ConsumerWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProductsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("All Products")),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(allProductsProvider.future),
        child: allProductsAsync.when(
          data: (products) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => ProductListItem(product: products[index]),
          ),
          loading: () => Skeletonizer(child: ProductListSkeleton()),
          error: (e, st) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}