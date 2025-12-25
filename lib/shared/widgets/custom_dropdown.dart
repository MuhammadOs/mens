import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.labelText,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  final String labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDisabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // Use the theme for consistent styling
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDisabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            // The hintText will show when no value is selected
            hintText: hintText,
            // Use the global input decoration theme
            fillColor: isDisabled
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : theme.inputDecorationTheme.fillColor,
            filled: true,
            border: theme.inputDecorationTheme.border,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDisabled
                    ? theme.colorScheme.outline.withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withAlpha(50),
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            focusedBorder: theme.inputDecorationTheme.focusedBorder,
            errorBorder: theme.inputDecorationTheme.errorBorder,
            focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          // Background color of the dropdown menu itself
          dropdownColor: theme.colorScheme.surface,
          iconEnabledColor: isDisabled
              ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          iconDisabledColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
