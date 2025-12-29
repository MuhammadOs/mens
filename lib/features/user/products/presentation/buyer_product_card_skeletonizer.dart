import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BuyerProductCardSkeleton extends StatelessWidget {
  const BuyerProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      child: Container(
        decoration: BoxDecoration(
          // Use the surface color defined in AppTheme
          // (Light: _lightGrey, Dark: _mediumDarkBlue)
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Subtle border adapting to light/dark mode
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Expanded(
              child: Bone(
                width: double.infinity,
                // Ensure top corners match container
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),

            // Content Placeholders
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Title Placeholder
                  const Bone.text(words: 2),
                  const SizedBox(height: 8),

                  // Price and Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Add Button Placeholder
                      Bone.circle(
                        size: 28,
                        // Optional: This will use the skeleton color,
                        // but represents the primary color button location
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
