import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/admin/admin_repository.dart';
import 'package:mens/features/admin/brands/domain/brand.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllBrandsView extends ConsumerWidget {
  const AllBrandsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBrandsAsync = ref.watch(allBrandsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("All Brands")), // TODO: Localize
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(allBrandsProvider.future),
        child: allBrandsAsync.when(
          data: (brands) => ListView.builder(
            itemCount: brands.length,
            itemBuilder: (context, index) => _BrandListItem(brand: brands[index]),
          ),
          loading: () => Skeletonizer(child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => ListTile(
              leading: Bone(borderRadius: BorderRadius.circular(24)),
              title: Bone.text(),
              subtitle: Bone.text(width: 100),
            ),
          )),
          error: (e, st) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}

class _BrandListItem extends StatelessWidget {
  const _BrandListItem({required this.brand});
  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.storefront)),
      title: Text(brand.brandName, style: theme.textTheme.titleMedium),
      subtitle: Text("Owner: ${brand.ownerName}  •  Products: ${brand.productCount}"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () { /* TODO: Navigate to brand details screen */ },
    );
  }
}