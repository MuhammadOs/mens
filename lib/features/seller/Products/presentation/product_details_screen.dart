import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/seller/Products/data/product_repository.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/features/user/cart/notifiers/cart_notifier.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:mens/shared/utils/ui_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// New Widgets
import 'package:mens/features/user/products/presentation/widgets/product_image_gallery.dart';
import 'package:mens/features/user/products/presentation/widgets/product_info_section.dart';
import 'package:mens/features/user/products/presentation/widgets/floating_cart_bar.dart';

class ProductDetailsScreen extends HookConsumerWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenshotKey = useMemoized(() => GlobalKey());

    // --- FETCH FRESH DETAILS ---
    final productAsync = ref.watch(productByIdProvider(product.id));
    final displayedProduct = productAsync.value ?? product;

    // --- STATE ---
    final currentImageIndex = useState(0);
    final quantity = useState(1);
    final userProfileAsync = ref.watch(authNotifierProvider);
    final userProfile = userProfileAsync.asData?.value;
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
      final cartItem = CartItem(
        id: displayedProduct.id.toString(),
        title: displayedProduct.name,
        price: displayedProduct.price,
        image: displayedProduct.primaryImageUrl ?? '',
        storeId: displayedProduct.storeId,
        quantity: quantity.value,
      );

      ref.read(cartNotifierProvider.notifier).addItem(cartItem);

      // Use shared premium feedback
      showPremiumCartFeedback(
        context,
        ref,
        title: "${quantity.value} x ${displayedProduct.name}",
        imageUrl: displayedProduct.primaryImageUrl,
      );
    }

    Future<void> shareScreenshot() async {
      try {
        final box = context.findRenderObject() as RenderBox?;
        final boundary =
            screenshotKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;

        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final pngBytes = byteData!.buffer.asUint8List();

          final tempDir = await getTemporaryDirectory();
          final file = await File(
            '${tempDir.path}/product_screenshot.png',
          ).create();
          await file.writeAsBytes(pngBytes);

          // ignore: deprecated_member_use
          await Share.shareXFiles(
            [XFile(file.path)],
            text:
                'Check out ${displayedProduct.name}!\nPrice: \$${displayedProduct.price.toStringAsFixed(2)}\n\n${displayedProduct.description}',
            subject: 'Check out this product: ${displayedProduct.name}',
            sharePositionOrigin: box != null
                ? box.localToGlobal(Offset.zero) & box.size
                : null,
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
                  expandedHeight: 450,
                  pinned: true,
                  backgroundColor: theme.colorScheme.surface,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppBackButton(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      iconColor: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: shareScreenshot,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                        ),
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductImageGallery(
                      product: displayedProduct,
                      currentImageIndex: currentImageIndex,
                    ),
                  ),
                ),

                // 2. Product Info Body
                SliverToBoxAdapter(
                  child: ProductInfoSection(
                    product: displayedProduct,
                    theme: theme,
                  ),
                ),
              ],
            ),

            // 3. Floating Bottom Bar
            if (role == "User")
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: FloatingCartBar(
                  quantity: quantity.value,
                  price: displayedProduct.price,
                  onIncrement: incrementQuantity,
                  onDecrement: decrementQuantity,
                  onAddToCart: addToCart,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
