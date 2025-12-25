import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/Products/presentation/product_details_screen.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/features/user/cart/presentation/notifiers/user_nav_provider.dart';
import 'package:mens/features/user/products/presentation/product_card_extensions.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
            // child: const Icon(FontAwesomeIcons.shirt, size: 50, color: Colors.orange),
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
                  FontAwesomeIcons.plus,
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

// buyer_product_card.dart

class BuyerProductCard extends HookConsumerWidget {
  final Product product;

  const BuyerProductCard({super.key, required this.product});

  // --- CART LOGIC ---
  void _addToCart(BuildContext context, ref) {
    final repo = CartRepository.instance;

    // 1. Map to Cart Item
    final cartItem = product.toCartItem();

    if (cartItem == null) {
      _showFeedback(context, 'Invalid product data', isError: true, ref: ref);
      return;
    }

    // 2. Add to Repo
    try {
      repo.addItem(cartItem);
      _showFeedback(context, 'Added "${product.name}" to cart', ref: ref);
    } catch (e) {
      _showFeedback(context, 'Failed to add to cart', isError: true, ref: ref);
    }
  }

  void _showFeedback(
    BuildContext context,
    String message, {
    bool isError = false,
    WidgetRef? ref,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: isError
            ? null
            : SnackBarAction(
                label: 'VIEW',
                onPressed: () {
                  ref?.read(adminNavIndexProvider.notifier).state = 0;
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final role = userProfile?.role ?? 'User';
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.primaryImageUrl != null)
                    Image.network(
                      product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          FontAwesomeIcons.image,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        FontAwesomeIcons.image,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category / Brand
                  Text(
                    product.subCategoryName.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Title
                  Text(
                    product.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price & Add Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (role != "Admin")
                      Material(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => _addToCart(context, ref),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              FontAwesomeIcons.cartPlus,
                              size: 12,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
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
  }
}
