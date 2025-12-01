import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/user/cart/presentation/all_orders_screen.dart';
import 'package:mens/features/user/cart/presentation/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllOrdersScreen()),
            ),
            icon: Icon(Icons.receipt_long, color: theme.colorScheme.onSurface),
            label: Text(
              "Orders",
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: _repo.items,
        builder: (context, items, _) {
          return items.isEmpty
              ? _buildEmptyState(theme)
              : _buildCartList(theme, items);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            "Your cart is empty",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.storefront_outlined),
            label: Text("Start Shopping"),
            onPressed: () {
              context.go(AppRoutes.adminProducts);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(ThemeData theme, List<CartItem> cartItems) {
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
                  child: Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
                onDismissed: (_) {
                  _removeItem(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed "${item.title}"')),
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
                              '\${item.price.toStringAsFixed(2)}',
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
                                  'Subtotal: \${item.subtotal.toStringAsFixed(2)}',
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _increment(index),
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        child: Icon(
                                          Icons.add,
                                          size: 16,
                                          color: theme.colorScheme.onPrimary,
                                        ),
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
                      'Total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\${total.toStringAsFixed(2)}',
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
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // go to checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(items: cartItems),
                    ),
                  );
                },
                child: Text('Checkout', style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear cart'),
                      content: const Text(
                        'Are you sure you want to remove all items from the cart?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
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

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return const SizedBox.shrink();
  }
}
