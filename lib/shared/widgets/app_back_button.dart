import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.size = 40, // Increased slightly for better touch targets
    this.outlined = false,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.elevation = 0,
    this.icon,
    this.tooltip = 'Back',
  });

  final VoidCallback? onPressed;
  final double size;
  final bool outlined;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final double elevation;
  final IconData? icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 1. Determine Colors dynamically based on Theme if not provided
    // Using strict logic to handle the specific "Dark Blue" default you had,
    // or falling back to theme colors.
    final defaultFilledColor = backgroundColor ?? const Color(0xFF0F3B5C);

    final effectiveBgColor = outlined ? Colors.transparent : defaultFilledColor;

    final effectiveIconColor =
        iconColor ?? (outlined ? colorScheme.primary : Colors.white);

    // 2. Define Border
    final borderSide = outlined
        ? BorderSide(color: colorScheme.primary, width: 1.5)
        : BorderSide.none;

    // 3. Smart Icon Sizing (Preserving your logic)
    final effectiveIconSize = iconSize ?? (size * 0.5).clamp(16.0, size * 0.7);

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: effectiveBgColor,
        elevation: elevation,
        type: MaterialType.button,
        // Changed to Squircle (Rounded Rect) for a more premium look matching the cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: Center(
            child: Tooltip(
              message: tooltip,
              child: Icon(
                // 4. Adaptive Icon (Android vs iOS style)
                icon ?? FontAwesomeIcons.arrowLeft,
                color: effectiveIconColor,
                size: effectiveIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
