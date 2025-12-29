import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.outlined = false,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.elevation = 0,
    this.icon,
    this.tooltip = 'Back',
  });

  final VoidCallback? onPressed;
  final bool outlined;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final double elevation;
  final IconData? icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () => Navigator.of(context).maybePop(),
      child: Center(
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icon ?? FontAwesomeIcons.arrowLeft,
            size: 20,
          ),
        ),
      ),
    );
  }
}
