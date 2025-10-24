import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/admin/presentation/all_brands_view.dart';
import 'package:mens/features/admin/presentation/all_products_view.dart';

class AdminHomeScreen extends HookConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    final screens = [const AllProductsView(), const AllBrandsView()];

    return Scaffold(
      body: IndexedStack(index: selectedIndex.value, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            label: "All Products", // TODO: Localize
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            label: "All Brands", // TODO: Localize
          ),
        ],
      ),
    );
  }
}
