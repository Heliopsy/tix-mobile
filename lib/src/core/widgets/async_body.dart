// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

/// Draws [value]: [loading] (a list skeleton by default) while it first
/// loads, an [ErrorState] with a retry when it fails, and [data] otherwise.
class AsyncBody<T> extends StatelessWidget {
  /// Draws [value] with [data], retrying with [onRetry].
  const AsyncBody({
    required this.value,
    required this.data,
    required this.onRetry,
    this.loading,
    super.key,
  });

  /// The value to draw.
  final AsyncValue<T> value;

  /// Draws the loaded value.
  final Widget Function(T value) data;

  /// Called by the error state's retry button.
  final VoidCallback onRetry;

  /// Drawn while loading; a [SkeletonList] when null.
  final Widget? loading;

  @override
  Widget build(BuildContext context) => value.when(
    data: data,
    loading: () => loading ?? const SkeletonList(),
    error: (e, _) => ErrorState(error: e, onRetry: onRetry),
  );
}
