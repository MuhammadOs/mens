import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/features/user/cart/presentation/all_orders_screen.dart';
import 'package:mens/features/user/cart/presentation/checkout_screen.dart';
import 'package:mens/features/user/cart/presentation/notifiers/user_nav_provider.dart';
import 'package:mens/features/user/cart/presentation/widgets/cart_item_card.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _repo = CartRepository.instance;

  void _increment(int index) {
    final current = List<CartItem>.from(_repo.items.value);
    if (index >= 0 && index < current.length) {
      current[index].quantity++;
      _repo.items.value = current;
    }
  }

  void _decrement(int index) {
    final current = List<CartItem>.from(_repo.items.value);
    if (index >= 0 && index < current.length) {
      if (current[index].quantity > 1) current[index].quantity--;
      _repo.items.value = current;
    }
  }

  void _removeItem(int index) {
    final current = List<CartItem>.from(_repo.items.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _repo.items.value = current;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.cart),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllOrdersScreen()),
            ),
            icon: Icon(FontAwesomeIcons.receipt, color: Colors.white),
            label: Text(
              l10n.cartOrders, // Localized
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: _repo.items,
        builder: (context, items, _) {
          return items.isEmpty
              // Pass l10n to helper methods
              ? _buildEmptyState(theme, l10n)
              : _buildCartList(theme, l10n, items);
        },
      ),
    );
  }

  // Updated signature to accept l10n
  Widget _buildEmptyState(ThemeData theme, dynamic l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.cartShopping,
            size: 92,
            color: theme.colorScheme.onSurface.withOpacity(0.12),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.cartEmptyTitle, // Localized
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.shop),
            label: Text(l10n.cartStartShopping), // Localized
            onPressed: () {
              ref.read(adminNavIndexProvider.notifier).state = 0;
            },
          ),
        ],
      ),
    );
  }

  // Updated signature to accept l10n
  Widget _buildCartList(
    ThemeData theme,
    dynamic l10n,
    List<CartItem> cartItems,
  ) {
    final total = cartItems.fold<double>(0, (s, e) => s + e.subtotal);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItemCard(
                key: ValueKey(item.id),
                item: item,
                onIncrement: () => _increment(index),
                onDecrement: () => _decrement(index),
                onRemove: () {
                  _removeItem(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.cartItemRemoved(item.title))),
                  );
                },
              );
            },
          ),
        ),

        // Bottom summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cartTotal, // Localized
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final authState = ref.read(authNotifierProvider);
                  // Check for guest by userId == 0
                  final isGuest = authState.asData?.value?.userId == 0;

                  if (isGuest) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.signIn), // Reusing 'Sign In'
                        content: const Text(
                          'You need to sign in to checkout.',
                        ), // TODO: Localize
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cartClearDialogCancel,
                            ), // Reusing 'Cancel'
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(authNotifierProvider.notifier).logout();
                              context.go(
                                '/signIn',
                              ); // Using explicit route string as in AppRouter.signIn
                            },
                            child: Text(l10n.signIn),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(items: cartItems),
                    ),
                  );
                },
                child: Text(
                  l10n.cartCheckout,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ), // Localized
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.cartClearDialogTitle), // Localized
                      content: Text(l10n.cartClearDialogContent), // Localized
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cartClearDialogCancel), // Localized
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.cartClearDialogConfirm), // Localized
                        ),
                      ],
                    ),
                  );
                  if (confirm ?? false) {
                    _repo.clear();
                  }
                },
                icon: Icon(
                  FontAwesomeIcons.trashCan,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
