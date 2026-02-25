import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/Products/presentation/product_details_screen.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/features/user/products/presentation/product_card_extensions.dart';
import 'package:mens/features/user/cart/notifiers/cart_notifier.dart';

import 'package:mens/shared/utils/ui_utils.dart';

// Use shared theming and assets; this component is style-agnostic and uses
// the current Theme for colors and text styles so it integrates with the app.

class ProductCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                  _addToCartAndNotify(context, ref, newItem);
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
      CartItemShim(
        title: title,
        price: price,
        image: image,
        storeId: 1,
      ); // Default storeId for demo

  Future<void> _addToCartAndNotify(
    BuildContext context,
    WidgetRef ref,
    CartItemShim shim,
  ) async {
    final cartItem = CartItem(
      id: shim.id,
      title: shim.title,
      price: shim.price,
      image: shim.image,
      storeId: shim.storeId,
    );

    try {
      await ref.read(cartNotifierProvider.notifier).addItem(cartItem);

      if (context.mounted) {
        showPremiumCartFeedback(
          context,
          ref,
          title: shim.title,
          imageUrl: shim.image,
        );
      }
    } on DifferentStoreCartException catch (_) {
      if (context.mounted) {
        final shouldClear = await showClearCartDialog(context);
        if (shouldClear == true && context.mounted) {
          // Clear cart then add
          await ref.read(cartNotifierProvider.notifier).clear();
          await ref.read(cartNotifierProvider.notifier).addItem(cartItem);
          if (context.mounted) {
            showPremiumCartFeedback(
              context,
              ref,
              title: shim.title,
              imageUrl: shim.image,
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    }
  }
}

// Simple shim used to avoid immediate import cycles in small patch; the repository will accept this.
class CartItemShim {
  final String title;
  final double price;
  final String image;
  final int storeId;
  CartItemShim({
    required this.title,
    required this.price,
    required this.image,
    required this.storeId,
  });

  String get id => title; // demo id
}

// buyer_product_card.dart

class BuyerProductCard extends HookConsumerWidget {
  final Product product;

  const BuyerProductCard({super.key, required this.product});

  // --- CART LOGIC ---
  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    // 1. Map to Cart Item
    final cartItem = product.toCartItem();

    if (cartItem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid product data')));
      return;
    }

    // 2. Add to Repo
    try {
      await ref.read(cartNotifierProvider.notifier).addItem(cartItem);
      if (context.mounted) {
        showPremiumCartFeedback(
          context,
          ref,
          title: product.name,
          imageUrl: product.primaryImageUrl,
        );
      }
    } on DifferentStoreCartException catch (_) {
      if (context.mounted) {
        final shouldClear = await showClearCartDialog(context);
        if (shouldClear == true && context.mounted) {
          await ref.read(cartNotifierProvider.notifier).clear();
          await ref.read(cartNotifierProvider.notifier).addItem(cartItem);
          if (context.mounted) {
            showPremiumCartFeedback(
              context,
              ref,
              title: product.name,
              imageUrl: product.primaryImageUrl,
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final role = userProfile?.role ?? 'User';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.primaryImageUrl != null)
                    Image.network(
                      product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                    )
                  else
                    _buildPlaceholder(theme),
                ],
              ),
            ),

            // Details Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category / Brand
                    Text(
                      product.subCategoryName.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Title
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Price & Add Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (role != "Admin")
                          Material(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () => _addToCart(context, ref),
                              borderRadius: BorderRadius.circular(10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Center(
        child: Icon(
          FontAwesomeIcons.image,
          size: 32,
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

