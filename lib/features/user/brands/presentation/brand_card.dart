import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mens/features/user/brands/domain/brand.dart';
import 'package:mens/features/user/brands/presentation/brand_details_screen.dart';

class BrandCard extends StatelessWidget {
  const BrandCard({required this.brand});
  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BrandDetailsScreen(brand: brand)),
        );
      },
      child: Container(
        // Transparent color ensures clicks are registered even on empty space within the column
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand Image - Circular
            Flexible(
              flex: 3,
              child: Hero(
                tag:
                    'brand_${brand.id}', // Matches the tag in BrandDetailsScreen
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: brand.brandImage != null
                      ? ClipOval(
                          child: Image.network(
                            brand.brandImage!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              FontAwesomeIcons.store,
                              size: 32,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Icon(
                          FontAwesomeIcons.store,
                          size: 32,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Brand Name
            Flexible(
              flex: 2,
              child: Text(
                brand.brandName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 2),

            // Owner Name
            Text(
              brand.ownerName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // Category
            Text(
              brand.categoryName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
