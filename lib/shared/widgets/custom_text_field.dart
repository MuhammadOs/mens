import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.validator,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.onChanged,
    this.textDirection,
    this.textAlign, // <-- 1. ADDED THIS PROPERTY
  });

  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final ValueChanged<String>? onChanged;
  final ui.TextDirection? textDirection;
  final TextAlign? textAlign; // <-- 1. ADDED THIS PROPERTY

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;

    // Determine if the clear button should be shown
    final showClearButton =
        !isPassword && (controller?.text.isNotEmpty ?? false);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      obscureText: isPassword && !isPasswordVisible,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      textDirection: textDirection,
      // 2. PASSED THE PROPERTY HERE
      // Default to TextAlign.start if nothing is provided
      textAlign: textAlign ?? TextAlign.start,
      // Use the theme's text style for consistency
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Inherit styles from the global theme for better consistency
        labelStyle: inputDecorationTheme.labelStyle?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: inputDecorationTheme.hintStyle,
        floatingLabelStyle: inputDecorationTheme.floatingLabelStyle?.copyWith(
          color: theme.colorScheme.primary,
        ),
        // Use the theme's fill color
        fillColor: inputDecorationTheme.fillColor,
        filled: true,
        // Border styles are now more concise
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withAlpha(200),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withAlpha(50),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        // Suffix icon logic now handles password visibility AND the clear button
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: onVisibilityToggle,
              )
            : (showClearButton
                  ? IconButton(
                      icon: Icon(
                        FontAwesomeIcons.xmark,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () => controller?.clear(),
                    )
                  : null),
      ),
    );
  }
}
