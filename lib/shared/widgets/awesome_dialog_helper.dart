import 'dart:async';
import 'package:flutter/material.dart';

/// A helper class to show consistent, "awesome" modal dialogs for
/// loading, success, and error states.
class AwesomeDialogHelper {
  /// RECOMMENDED: Handles the full API request flow with dialogs.
  ///
  /// This will:
  /// 1. Show a loading dialog.
  /// 2. Run your [future] (the API call).
  /// 3. Close the loading dialog.
  /// 4. If successful, show a [successTitle] dialog.
  /// 5. If it fails, show an [errorTitle] dialog.
  ///
  /// Returns `true` if the future succeeded, `false` if it failed.
  static Future<bool> handleApiRequest({
    required BuildContext context,
    required Future<void> future,
    required String loadingMessage,
    required String errorTitle,
    String? successTitle,
    String? successMessage,
    String okText = "OK",
    bool autoDismissSuccess = false,
    VoidCallback? onSuccessOk,
  }) async {
    // Capture a stable root context before any awaits to avoid using
    // the (possibly disposed) caller context after async gaps.
    final rootCtx = Navigator.of(context, rootNavigator: true).context;

    // 1. Show Loading using the root context so the dialog attaches to the
    // app-level navigator and is less likely to be affected by widget disposal.
    final loadingNotifier = _showLoadingDialog(
      rootCtx,
      message: loadingMessage,
    );

    try {
      // 2. Run the Future
      await future;

      // 3. Close Loading
      _closeLoadingDialog(loadingNotifier);

      // 4. Show Success (if title is provided)
      if (successTitle != null) {
        if (rootCtx.mounted) {
          await _showSuccessDialog(
            rootCtx,
            title: successTitle,
            message: successMessage,
            autoDismiss: autoDismissSuccess,
            okText: okText,
            onOk: onSuccessOk,
          );
        }
      }
      return true; // API call succeeded
    } catch (e) {
      // 5. Close Loading
      _closeLoadingDialog(loadingNotifier);

      // 6. Show Error using the previously-captured root context
      if (rootCtx.mounted) {
        await _showErrorDialog(
          rootCtx,
          title: errorTitle,
          message: e.toString().replaceAll("Exception: ", ""),
          okText: okText,
        );
      }
      return false; // API call failed
    }
  }

  // --- PRIVATE HELPERS ---
  // These are the original functions, now made private.
  // The `handleApiRequest` method is the new public API.

  /// Shows a non-dismissible loading dialog.
  static ValueNotifier<bool> _showLoadingDialog(
    BuildContext context, {
    required String message,
  }) {
    final closeNotifier = ValueNotifier<bool>(false);

    // This Future.delayed(Duration.zero) is CRITICAL.
    // It pushes the showDialog call to the next frame, ensuring
    // that it doesn't conflict with any other state changes
    // (like the button's state) that just happened.
    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ValueListenableBuilder<bool>(
            valueListenable: closeNotifier,
            builder: (context, shouldClose, child) {
              if (shouldClose && Navigator.of(context).canPop()) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop();
                });
              }
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  content: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 24),
                      Text(message),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });

    return closeNotifier;
  }

  /// Closes a dialog opened with [_showLoadingDialog].
  static void _closeLoadingDialog(ValueNotifier<bool> closeNotifier) {
    closeNotifier.value = true;
  }

  /// Shows an "awesome" success dialog.
  static Future<void> _showSuccessDialog(
    BuildContext context, {
    required String title,
    String? message,
    bool autoDismiss = false,
    String okText = "OK",
    VoidCallback? onOk,
  }) async {
    if (autoDismiss) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 30),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            content: message != null ? Text(message) : null,
          );
        },
      ).then((_) => onOk?.call());
    } else {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: message != null ? Text(message) : null,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
              child: Text(okText),
            ),
          ],
        ),
      );
    }
  }

  /// Shows an "awesome" error dialog.
  static Future<void> _showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String okText = "OK",
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(okText),
          ),
        ],
      ),
    );
  }
}
