import 'package:flutter/material.dart';
import 'package:mens/features/user/cart/cart.dart';

// Use shared theming and assets; this component is style-agnostic and uses
// the current Theme for colors and text styles so it integrates with the app.

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePlaceholder; // Use assets in real app

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imagePlaceholder = 'assets/mens_logo.png', // Replace with real image
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image Container
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(imagePlaceholder, fit: BoxFit.contain),
            // Note: Ensure you have an asset or use Icon for testing:
            // child: const Icon(Icons.checkroom, size: 50, color: Colors.orange),
          ),
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Price and Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$price\$",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            InkWell(
              onTap: () {
                // Add item to shared cart repository
                try {
                  final priceValue = double.tryParse(price) ?? 0.0;
                  final newItem =
                      // use title as id for demo; in real app use product id
                      ProductCard._toCartItem(
                        title,
                        priceValue,
                        imagePlaceholder,
                      );
                  // avoid import cycle by using delayed import via repository
                  // but here we import directly
                  // ignore: avoid_dynamic_calls
                  _addToCartAndNotify(context, newItem);
                } catch (_) {}
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static _toCartItem(String title, double price, String image) =>
      // return a minimal cart model-like map; will be converted in repository helper
      CartItemShim(title: title, price: price, image: image);

  void _addToCartAndNotify(BuildContext context, CartItemShim shim) {
    final repo = CartRepository.instance;
    final cartItem = CartItem(
      id: shim.id,
      title: shim.title,
      price: shim.price,
      image: shim.image,
    );
    repo.addItem(cartItem);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added "${shim.title}" to cart')));
  }
}

// Simple shim used to avoid immediate import cycles in small patch; the repository will accept this.
class CartItemShim {
  final String title;
  final double price;
  final String image;
  CartItemShim({required this.title, required this.price, required this.image});

  String get id => title; // demo id
}
