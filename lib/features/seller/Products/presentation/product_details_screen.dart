import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/shared/widgets/staggered_slide_fade.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsScreen extends HookConsumerWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenshotKey = useMemoized(() => GlobalKey());

    // --- FETCH FRESH DETAILS ---
    // Refetch product details to ensure we have fields like stockQuantity
    // which might be missing from the list items.
    final productAsync = ref.watch(productByIdProvider(product.id));
    
    // Use fresh data if available, otherwise fallback to passed product
    final displayedProduct = productAsync.value ?? product;

    // --- STATE ---
    final currentImageIndex = useState(0);
    final quantity = useState(1);
    final pageController = usePageController();
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final role = userProfile?.role ?? 'User';

    // --- LOGIC ---
    void incrementQuantity() {
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
        id: displayedProduct.id.toString(),
        title: displayedProduct.name,
        price: displayedProduct.price,
        image: displayedProduct.primaryImageUrl ?? '',
        storeId: displayedProduct.storeId,
        quantity: quantity.value,
      );

      repo.addItem(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${quantity.value} x "${displayedProduct.name}" to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.primary,
        ),
      );
    }

    // --- SHARED LOGIC ---
    Future<void> shareScreenshot() async {
      try {
        final box = context.findRenderObject() as RenderBox?;
        final boundary = screenshotKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          final pngBytes = byteData!.buffer.asUint8List();
          
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/product_screenshot.png').create();
          await file.writeAsBytes(pngBytes);
          
          await Share.shareXFiles(
            [XFile(file.path)], 
            text: 'Check out ${displayedProduct.name}!\nPrice: \$${displayedProduct.price.toStringAsFixed(2)}\n\n${displayedProduct.description}',
            subject: 'Check out this product: ${displayedProduct.name}',
            sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
          );
        }
      } catch (e) {
        debugPrint("Error capturing screenshot: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to share screenshot')),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RepaintBoundary(
        key: screenshotKey,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // 1. Immersive App Bar with Image Carousel
                SliverAppBar(
                  expandedHeight: 450, // Taller image area
                  pinned: true,
                  backgroundColor: theme.colorScheme.surface,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppBackButton(
                      backgroundColor: Colors.black.withValues(alpha: 0.3), // Glassy look
                      iconColor: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  actions: [
                     // Share Button
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: IconButton(
                         onPressed: shareScreenshot,
                         style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.3)),
                         icon: const Icon(Icons.share, color: Colors.white, size: 20),
                       ),
                     ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image PageView
                        if (displayedProduct.imageUrls.isNotEmpty)
                          PageView.builder(
                            controller: pageController,
                            itemCount: displayedProduct.imageUrls.length,
                            onPageChanged: (index) => currentImageIndex.value = index,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // TODO: Fullscreen Image View
                                },
                                child: Hero(
                                  tag: 'product_${displayedProduct.id}',
                                  child: Image.network(
                                    displayedProduct.imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      child: Icon(FontAwesomeIcons.image, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Container(color: theme.colorScheme.surfaceContainerHighest, child: Icon(FontAwesomeIcons.image, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
  
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                ],
                                stops: const [0.0, 0.2, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ),
  
                        // Page Indicators
                        if (displayedProduct.imageUrls.length > 1)
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(displayedProduct.imageUrls.length, (index) {
                                final isActive = currentImageIndex.value == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  height: 6,
                                  width: isActive ? 24 : 6,
                                  decoration: BoxDecoration(
                                    color: isActive ? theme.colorScheme.primary : Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
  
                // 2. Product Info Body
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), // Rounded top sheet effect
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0,-5))]
                    ),
                    transform: Matrix4.translationValues(0, -20, 0), // Slight overlap with image
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Store & Rating Row
                          StaggeredSlideFade(
                            index: 0,
                            child: Row(
                              children: [
                                if (displayedProduct.storeName != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.store, size: 14, color: theme.colorScheme.primary),
                                        const SizedBox(width: 6),
                                        Text(
                                          displayedProduct.storeName!.toUpperCase(),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
  
                          // Title & Price
                          StaggeredSlideFade(
                            index: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayedProduct.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${displayedProduct.price.toStringAsFixed(2)}",
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Stock Indicator
                                    Builder(
                                      builder: (context) {
                                        final stock = displayedProduct.stockQuantity;
                                        final quantity = stock; 
                                        final isInStock = quantity > 0;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                               Container(
                                                 width: 8, height: 8,
                                                 decoration: BoxDecoration(
                                                   color: isInStock ? Colors.green : Colors.red,
                                                   shape: BoxShape.circle,
                                                 ),
                                               ),
                                               const SizedBox(width: 6),
                                               Text(
                                                 isInStock ? 'In Stock ($quantity)' : 'Out of Stock ($quantity)', // Added quantity for verification
                                                 style: theme.textTheme.bodySmall?.copyWith(
                                                   color: isInStock ? Colors.green : Colors.red,
                                                   fontWeight: FontWeight.bold,
                                                 ),
                                               ),
                                            ],
                                          ),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
  
                          const SizedBox(height: 24),
                          Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 24),
  
                          // Description
                          StaggeredSlideFade(
                            index: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description",
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text( // We can make this expandable later if needed
                                  displayedProduct.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
  
  
                          // Bottom Padding for Floating Bar
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 3. Floating Bottom Bar with Blur
            if (role == "User")
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: ClipRRect( // Clip for blur
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface, 
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                           // Quantity
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                             decoration: BoxDecoration(
                               color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(
                               children: [
                                 _QuantityButton(icon: FontAwesomeIcons.minus, onTap: decrementQuantity, isEnabled: quantity.value > 1),
                                 SizedBox(width: 24, child: Text(quantity.value.toString(), textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                 _QuantityButton(icon: FontAwesomeIcons.plus, onTap: incrementQuantity, isEnabled: true),
                               ],
                             ),
                           ),
                           const SizedBox(width: 16),
                           // Add To Cart
                           Expanded(
                             child: SizedBox(
                               height: 54,
                               child: ElevatedButton(
                                 onPressed: addToCart,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: theme.colorScheme.primary,
                                   foregroundColor: theme.colorScheme.onPrimary,
                                   elevation: 0,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                 ),
                                 child: const Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Icon(FontAwesomeIcons.bagShopping, size: 18),
                                     SizedBox(width: 8),
                                     Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                   ],
                                 ),
                               ),
                             ),
                           ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
