import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/user/cart/presentation/notifiers/user_nav_provider.dart';
import 'package:mens/features/user/brands/presentation/all_brands_view.dart';
import 'package:mens/features/user/admin_users/presentation/admin_users_view.dart';
import 'package:mens/features/user/conversations/presentation/conversations_view.dart';
import 'package:mens/features/user/products/presentation/all_products_view.dart';
import 'package:mens/features/user/tryon/presentation/tryon_screen.dart';
import 'package:mens/features/user/cart/presentation/cart_screen.dart';
import 'package:mens/features/user/profile/presentation/user_profile_screen.dart';

// This controls the active tab index for the Admin Home Screen

class UserHomeScreen extends HookConsumerWidget {
  final int initialIndex;

  const UserHomeScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(adminNavIndexProvider);
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
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
      if (userProfile?.role != "Admin") const CartScreen(),
      const AllBrandsView(),
      if (userProfile?.role != "Admin") const TryOnScreen(),
      if (userProfile?.role == "Admin") const ConversationsView(),
      if (userProfile?.role == "Admin") const AdminUsersView(),
      const UserProfileScreen(),
      const SizedBox.shrink(),
    ];

    final items = [
      BottomNavigationBarItem(
        icon: const Icon(FontAwesomeIcons.house),
        label: l10n.homeProducts,
      ),
      if (userProfile?.role != "Admin")
        BottomNavigationBarItem(
          icon: const Icon(FontAwesomeIcons.cartShopping),
          label: l10n.cart,
        ),
      BottomNavigationBarItem(
        icon: const Icon(FontAwesomeIcons.store),
        label: l10n.allBrandsTitle,
      ),
      if (userProfile?.role != "Admin")
        BottomNavigationBarItem(
          icon: const Icon(FontAwesomeIcons.shirt),
          label: l10n.tryOn,
        ),
      if (userProfile?.role == "Admin")
        BottomNavigationBarItem(
          icon: const Icon(FontAwesomeIcons.comments),
          label: l10n.conversations,
        ),
      if (userProfile?.role == "Admin")
        BottomNavigationBarItem(
          icon: const Icon(FontAwesomeIcons.users),
          label: l10n.adminUsersTitle,
        ),
      BottomNavigationBarItem(
        icon: const Icon(FontAwesomeIcons.user),
        label: l10n.profile,
      ),
    ];

    // Ensure index is valid for current items
    final safeIndex = selectedIndex >= items.length ? 0 : selectedIndex;

    // Verify screens length matches expected logic (ignoring the extra sizedbox) or at least covers safeIndex
    // We don't need to change screens logic as long as it maps 1:1 with items logic conceptually

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          height: 64,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          selectedIndex: safeIndex,
          onDestinationSelected: (index) {
            ref.read(adminNavIndexProvider.notifier).state = index;
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: items.map((item) {
            return NavigationDestination(
              icon: item.icon,
              label: item.label ?? '',
              tooltip: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
