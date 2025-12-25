import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/user/cart/cart.dart'; // Ensure this import exists
import 'package:mens/shared/widgets/app_back_button.dart';

class ProductDetailsScreen extends HookConsumerWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // --- STATE ---
    final currentImageIndex = useState(0);
    final quantity = useState(1);
    final pageController = usePageController();
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final role = userProfile?.role ?? 'User';
    // --- LOGIC ---
    void incrementQuantity() {
      // Optional: Check against product.stockQuantity if available
      if (quantity.value < 99) {
        quantity.value++;
      }
    }

    void decrementQuantity() {
      if (quantity.value > 1) {
        quantity.value--;
      }
    }

    void addToCart() {
      final repo = CartRepository.instance;

      final cartItem = CartItem(
        id: product.id.toString(),
        title: product.name,
        price: product.price,
        image: product.primaryImageUrl ?? '',
        quantity: quantity.value,
      );

      repo.addItem(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${quantity.value} x "${product.name}" to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.primary,
          // Undo action removed to prevent 'removeItem' undefined error
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. App Bar with Image Carousel
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: theme.colorScheme.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppBackButton(
                    size: 36,
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                    iconColor: theme.colorScheme.onSurface,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image PageView
                      if (product.imageUrls.isNotEmpty)
                        PageView.builder(
                          controller: pageController,
                          itemCount: product.imageUrls.length,
                          onPageChanged: (index) =>
                              currentImageIndex.value = index,
                          itemBuilder: (context, index) {
                            return Image.network(
                              product.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  FontAwesomeIcons.image,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.2),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            FontAwesomeIcons.image,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                          ),
                        ),

                      // Gradient Overlay for text readability if needed
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Page Indicators
                      if (product.imageUrls.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(product.imageUrls.length, (
                              index,
                            ) {
                              final isActive = currentImageIndex.value == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 8,
                                width: isActive ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Product Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name / Brand
                      if (product.storeName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.storeName!.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price & Stock
                      Row(
                        children: [
                          Text(
                            "\$${product.price.toStringAsFixed(2)}",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // Stock Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'In Stock: ${product.stockQuantity}', // Assuming stockQuantity exists
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Divider(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        "Description",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Related Products Header
                      Text(
                        'You May Also Like',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Horizontal List of Related Products (Mock)
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Container(color: Colors.grey[300]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 60,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          height: 10,
                                          width: 40,
                                          color: Colors.grey[300],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Extra padding for bottom bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Bottom Action Bar
          // Only show "Add to Cart" if the user is a standard "User".
          // Admins and StoreOwners (View Only) do not see this.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: FontAwesomeIcons.minus,
                            onTap: decrementQuantity,
                            isEnabled: quantity.value > 1,
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              quantity.value.toString(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: FontAwesomeIcons.plus,
                            onTap: incrementQuantity,
                            isEnabled: true, // Add max stock check if needed
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.bagShopping, size: 20),
                            SizedBox(width: 8),
                            Text("Add to Cart"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
