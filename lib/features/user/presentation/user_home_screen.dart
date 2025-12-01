import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/presentation/all_brands_view.dart';
import 'package:mens/features/user/presentation/all_products_view.dart';
import 'package:mens/features/user/presentation/tryon_screen.dart';
import 'package:mens/features/user/cart/presentation/cart_screen.dart';
import 'package:mens/features/user/profile/presentation/profile_screen.dart';

class AdminHomeScreen extends HookConsumerWidget {
  final int initialIndex;

  const AdminHomeScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(initialIndex);
    final l10n = ref.watch(l10nProvider);

    final screens = [
      const AllProductsView(),
      const CartScreen(),
      const AllBrandsView(),
      const TryOnScreen(),
      const ProfileScreen(),
      const SizedBox.shrink(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex.value, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex.value,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          selectedIndex.value = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: l10n.homeProducts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_outlined),
            label: l10n.allBrandsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checkroom),
            label: l10n.tryOn,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
