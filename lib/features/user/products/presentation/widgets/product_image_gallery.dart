import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mens/features/seller/Products/domain/product.dart';

class ProductImageGallery extends HookWidget {
  final Product product;
  final ValueNotifier<int> currentImageIndex;

  const ProductImageGallery({
    super.key,
    required this.product,
    required this.currentImageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageController = usePageController();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image PageView
        if (product.imageUrls.isNotEmpty)
          PageView.builder(
            controller: pageController,
            itemCount: product.imageUrls.length,
            onPageChanged: (index) => currentImageIndex.value = index,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                // Optimize Zoom vs Swipe
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                onInteractionEnd: (details) {
                  // Optional: snap back or special logic if needed
                },
                child: Hero(
                  tag:
                      'product_${product.id}_image_$index', // Unique tag per image if possible, usually just id
                  // Fallback for list view hero which usually uses 'product_${product.id}'
                  // Actually, for list-to-detail hero, we need to match the tag used in the list.
                  // The list uses 'product_${product.id}'. We should use that for the FIRST image only or handle it carefully.
                  // For simplicity and effectiveness, we'll use the main tag for the first image or index 0.
                  // But since PageView builds lazily, we can try to use the tag for the first image.
                  child: Image.network(
                    product.imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        FontAwesomeIcons.image,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),

        // Gradient Overlay - Wrapped in IgnorePointer to allow PageView gestures through
        Positioned.fill(
          child: IgnorePointer(
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
        ),

        // Page Indicators
        if (product.imageUrls.length > 1)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(product.imageUrls.length, (index) {
                return AnimatedBuilder(
                  animation: currentImageIndex,
                  builder: (context, child) {
                    final isActive = currentImageIndex.value == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 24 : 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? theme.colorScheme.primary
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
      ],
    );
  }
}
