import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// Note: Ensure your AppLocalizations import is correct based on your project structure
// usually: import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/user/cart/presentation/all_orders_screen.dart';
import 'package:mens/features/user/cart/presentation/checkout_screen.dart';
import 'package:mens/features/user/cart/presentation/notifiers/user_nav_provider.dart';

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
            icon: Icon(Icons.receipt_long, color: Colors.white),
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
            Icons.remove_shopping_cart_outlined,
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
            icon: const Icon(Icons.storefront_outlined),
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
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
                onDismissed: (_) {
                  _removeItem(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    // Localized with parameter
                    SnackBar(content: Text(l10n.cartItemRemoved(item.title))),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.06,
                            ),
                            child: Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  // Localized with parameter
                                  l10n.cartItemSubtotal(
                                    item.subtotal.toStringAsFixed(2),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _decrement(index),
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            theme.colorScheme.surface,
                                        child: Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _increment(index),
                                      child: CircleAvatar(
                                        radius: 14,
                                        child: Icon(Icons.add, size: 16),
                                      ),
                                    ),
                                  ],
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
                  Icons.delete_outline,
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
