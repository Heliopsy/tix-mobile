// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Answers a provider's build from the cache when it can, then from the
/// server.
///
/// With nothing in [cached], this is `fresh()`. With a hit, the hit is
/// returned at once and `fresh()` runs afterwards: its value goes to
/// [onFresh] (set it as the provider's state there), its failure to
/// [onStale], and either is dropped once [ref] is no longer the live build,
/// so a slow answer never overwrites a newer one. `fresh()` starts on the
/// next event, after the build has delivered the hit, so the two can never
/// arrive the wrong way round.
Future<T> cachedFirst<T>({
  required Ref ref,
  required Future<T?> cached,
  required Future<T> Function() fresh,
  required void Function(T value) onFresh,
  void Function(Object error, StackTrace stack)? onStale,
}) async {
  final hit = await cached;
  if (hit == null) return await fresh();
  unawaited(
    Future(() async {
      final T value;
      try {
        value = await fresh();
      } on Object catch (e, s) {
        if (ref.mounted) onStale?.call(e, s);
        return;
      }
      if (ref.mounted) onFresh(value);
    }),
  );
  return hit;
}
