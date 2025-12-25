import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/shared/providers/loading_provider.dart';
import 'package:mens/shared/providers/overlay_suppression_provider.dart';

/// Global loading overlay that shows during API calls
/// Automatically managed by LoadingInterceptor in API service
class LoadingOverlay extends ConsumerWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final theme = Theme.of(context);
    final isSuppressed = ref.watch(
      // lazy import path
      // overlay suppression provider lets specific screens opt out
      // of the global blocking overlay
      // import path: package:mens/shared/providers/overlay_suppression_provider.dart
      overlaySuppressionProvider,
    );

    return Stack(
      children: [
        child,
        if (isLoading && !isSuppressed)
          Material(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 40, height: 40),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension to manually show/hide loading for non-API operations
extension LoadingExtension on WidgetRef {
  /// Show global loading overlay
  void showLoading() {
    read(loadingNotifierProvider.notifier).increment();
  }

  /// Hide global loading overlay
  void hideLoading() {
    read(loadingNotifierProvider.notifier).decrement();
  }
}
