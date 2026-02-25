import 'package:flutter/material.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // --- Core Colors (Enhanced) ---
  static const Color _darkBlue = Color(0xFF192A3C);
  static const Color _mediumDarkBlue = Color(
    0xFF20364e,
  ); // For dark theme cards/surfaces
  static const Color _deepDarkBlue = Color(
    0xFF0F1A28,
  ); // Deeper background for dark theme
  static const Color _white = Colors.white;
  static const Color _black = Colors.black;
  static const Color _lightGrey = Color(
    0xFFF0F2F5,
  ); // Softer light grey for surfaces
  static const Color _errorColor = Color(0xFFEF5350); // Standard red for errors

  // --- Light Theme (Enhanced) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _white,
    primaryColor:
        _darkBlue, // Primarily for legacy widgets, use ColorScheme.primary
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBlue,
      foregroundColor: _white,
      iconTheme: IconThemeData(color: _white),
      titleTextStyle: TextStyle(
        color: _white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary:
          _darkBlue, // Main brand color for interactive elements, primary buttons
      onPrimary: _white, // Text/icons on primary color
      secondary: _mediumDarkBlue, // New accent color
      onSecondary: _white, // Text on general background
      surface: _lightGrey, // Card/dialog background
      onSurface: _black, // Text/icons on card/dialog background
      error: _errorColor,
      onError: _white,
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkBlue,
        foregroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkBlue, // Text/icon color
        side: const BorderSide(color: _darkBlue, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _darkBlue,
      selectionColor: _darkBlue.withValues(alpha: 0.3),
      selectionHandleColor: _darkBlue,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: _black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: _black,
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: _black,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: _black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: _black,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ), // Used for "Sign In" title
      headlineSmall: TextStyle(
        color: _black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: _black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: _black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ), // Default for text field labels
      titleSmall: TextStyle(
        color: _black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: _black, fontSize: 16),
      bodyMedium: TextStyle(color: _black, fontSize: 14), // Default body text
      bodySmall: TextStyle(color: _black, fontSize: 12),
      labelLarge: TextStyle(
        color: _white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ), // For ElevatedButton text
      labelMedium: TextStyle(
        color: _black,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ), // For small labels/helper text
      labelSmall: TextStyle(
        color: _black,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _white, // Input fields are white
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.0,
        ), // Subtle grey border when not focused
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _mediumDarkBlue,
          width: 1.5,
        ), // Accent color on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: _black.withValues(alpha: 0.6)),
      floatingLabelStyle: const TextStyle(
        color: _mediumDarkBlue,
      ), // Floating label in accent color
      hintStyle: TextStyle(color: _black.withValues(alpha: 0.4)),
    prefixIconColor: _darkBlue.withValues(alpha: 0.7),
      suffixIconColor: _darkBlue.withValues(alpha: 0.7),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _white,
      indicatorColor: _darkBlue.withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          );
        }
        return TextStyle(
          fontSize: 12,
          color: _black.withValues(alpha: 0.6),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _darkBlue, size: 24);
        }
        return IconThemeData(
          color: _black.withValues(alpha: 0.6),
          size: 24,
        );
      }),
    ),
  );

  // --- Dark Theme (Enhanced) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _deepDarkBlue, // Deeper dark blue background
    primaryColor: _white, // Primarily for legacy widgets
    appBarTheme: const AppBarTheme(
      backgroundColor: _mediumDarkBlue,
      foregroundColor: _white,
      iconTheme: IconThemeData(color: _white),
      titleTextStyle: TextStyle(
        color: _white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _white, // Accent color for primary interactive elements
      onPrimary: _black, // Text/icons on primary (accent) color
      secondary:
          _white, // Secondary elements like icons or less prominent buttons
      onSecondary: _deepDarkBlue, // Text on general background
      surface:
          _mediumDarkBlue, // Card/dialog background (lighter than scaffold)
      onSurface: _white, // Text/icons on card/dialog background
      error: _errorColor,
      onError: _white,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _white, // Accent color for primary buttons
        foregroundColor: _black, // Black text on accent buttons for contrast
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _white, // Accent color for text/icon
        side: const BorderSide(color: _white, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _white,
      selectionColor: _white.withValues(alpha: 0.3),
      selectionHandleColor: _white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: _white,
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: _white,
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: _white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: _white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: _white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: _white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: _white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: _white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: _white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: _white, fontSize: 16),
      bodyMedium: TextStyle(color: _white, fontSize: 14),
      bodySmall: TextStyle(color: _white, fontSize: 12),
      labelLarge: TextStyle(
        color: _black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ), // For ElevatedButton text
      labelMedium: TextStyle(
        color: _white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: _white,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          _darkBlue, // Fields are dark blue (same as light theme primary)
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _white.withValues(alpha: 0.1),
          width: 1.0,
        ), // Subtle light border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _white,
          width: 1.5,
        ), // Accent color on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: _white.withValues(alpha: 0.6)),
      floatingLabelStyle: const TextStyle(
        color: _white,
      ), // Floating label in accent color
      hintStyle: TextStyle(color: _white.withValues(alpha: 0.4)),
    prefixIconColor: _white.withValues(alpha: 0.7),
      suffixIconColor: _white.withValues(alpha: 0.7),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _mediumDarkBlue,
      indicatorColor: _white.withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _white,
          );
        }
        return TextStyle(
          fontSize: 12,
          color: _white.withValues(alpha: 0.6),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _white, size: 24);
        }
        return IconThemeData(
          color: _white.withValues(alpha: 0.6),
          size: 24,
        );
      }),
    ),
  );
}
