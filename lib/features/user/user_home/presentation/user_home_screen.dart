import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/user/cart/presentation/notifiers/user_nav_provider.dart';
import 'package:mens/features/user/brands/presentation/all_brands_view.dart';
import 'package:mens/features/user/products/presentation/all_products_view.dart';
import 'package:mens/features/user/tryon/presentation/tryon_screen.dart';
import 'package:mens/features/user/cart/presentation/cart_screen.dart';
import 'package:mens/features/user/profile/presentation/profile_screen.dart';

// This controls the active tab index for the Admin Home Screen

class UserHomeScreen extends HookConsumerWidget {
  final int initialIndex;

  const UserHomeScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(adminNavIndexProvider);
    final l10n = ref.watch(l10nProvider);
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;
    useEffect(() {
      // Use microtask to avoid updating state during build
      Future.microtask(() {
        if (ref.read(adminNavIndexProvider) != initialIndex) {
          ref.read(adminNavIndexProvider.notifier).state = initialIndex;
        }
      });
      return null;
    }, [initialIndex]);
    final screens = [
      const AllProductsView(),
      if (userProfile?.role == "Admin") const CartScreen(),
      const AllBrandsView(),
      const TryOnScreen(),
      const ProfileScreen(),
      const SizedBox.shrink(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(adminNavIndexProvider.notifier).state = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: l10n.homeProducts,
          ),
          if (userProfile?.role == "Admin")
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: l10n.cart,
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
