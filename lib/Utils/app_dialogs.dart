import 'package:flutter/material.dart';

/// Lightweight, reusable dialogs/snackbars used across the app so error/feedback
/// feels consistent and professional.
class AppDialogs {
  AppDialogs._();

  static String prettyError(String raw) {
    final msg = raw.trim();
    if (msg.isEmpty) return 'Something went wrong. Please try again.';

    final lower = msg.toLowerCase();

    if (lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('timed out') ||
        lower.contains('timeout')) {
      return 'Looks like you’re offline or the connection is unstable. Please check your internet and try again.';
    }

    if (lower.contains('api key') || lower.contains('missing')) {
      return 'This feature isn’t available right now (missing configuration). Please try again later.';
    }

    if (lower.contains('unauthorized') ||
        lower.contains('401') ||
        lower.contains('403')) {
      return 'The service isn’t available right now. Please try again later.';
    }

    if (lower.contains('format') || lower.contains('json')) {
      return 'We couldn’t process the server response this time. Please try again.';
    }

    if (lower.contains('429') || lower.contains('rate')) {
      return 'Too many requests right now. Please wait a moment and try again.';
    }

    return msg;
  }

  /// Shows a user-friendly error dialog.
  ///
  /// - If [onRetry] is provided, we show a Retry button.
  /// - If [showExit] is true, we show an Exit button.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    bool showExit = true,
    String retryLabel = 'Retry',
    String exitLabel = 'Exit',
  }) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (showExit)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(exitLabel),
              ),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  onRetry();
                },
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
          ],
        );
      },
    );
  }

  /// A consistent success/info snackbar. Prefer this over toasts.
  static void showSnack(
    BuildContext context, {
    required String message,
    Color? background,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Optional confirmation dialog.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'No',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(cancelLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

