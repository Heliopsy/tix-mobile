// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// Draws [value]: a spinner while it first loads, an [ErrorView] with a retry
/// button when it fails, and [data] otherwise.
class AsyncBody<T> extends StatelessWidget {
  /// Draws [value] with [data], retrying with [onRetry].
  const AsyncBody({
    required this.value,
    required this.data,
    required this.onRetry,
    super.key,
  });

  /// The value to draw.
  final AsyncValue<T> value;

  /// Draws the loaded value.
  final Widget Function(T value) data;

  /// Called by the error view's retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => value.when(
    data: data,
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => ErrorView(error: e, onRetry: onRetry),
  );
}

/// A failure, explained, with a way to try again.
class ErrorView extends StatelessWidget {
  /// Explains [error], retrying with [onRetry].
  const ErrorView({required this.error, required this.onRetry, super.key});

  /// What went wrong.
  final Object error;

  /// Called by the retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(errorMessage(l10n, error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
