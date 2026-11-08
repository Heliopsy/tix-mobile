// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/time/time_style.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/models/time_settings.dart';
import 'package:tix_mobile/src/data/repositories/time_prefs_repository.dart';

export 'package:tix_mobile/src/data/models/time_settings.dart';

part 'reader_time.g.dart';

typedef _Target = ({String context, String baseUrl, Credential credential});

/// The active context's date settings: what was remembered for it at once,
/// then the server's answer. Null without a context, and from a server
/// that keeps none, which leaves the device's formats in force.
///
/// A connection that reaches one tenant is keyed by the connection alone,
/// as the response cache is, so `whoami` naming the tenant later does not
/// read the settings twice.
@Riverpod(keepAlive: true)
class ReaderTime extends _$ReaderTime {
  TimePrefsRepository? _repo;
  String _context = '';

  @override
  TimeSettings? build() {
    final target = ref.watch(
      sessionControllerProvider.select<_Target?>((s) {
        final session = s.value;
        if (session == null || session.problem != null) return null;
        final c = session.connection;
        return (
          context: '${c.id}.${c.switchable ? c.tenantKey : ''}',
          baseUrl: session.baseUrl,
          credential: session.credential,
        );
      }),
    );
    if (target == null) {
      _repo = null;
      return null;
    }
    final repo = TimePrefsRepository(
      ref.watch(tixApiFactoryProvider)(target.baseUrl, target.credential),
      ref.watch(keyValueStoreProvider),
    );
    _repo = repo;
    _context = target.context;
    unawaited(refresh());
    return repo.remembered(target.context);
  }

  /// Reads the settings again from the server; offline, what is shown
  /// stands.
  Future<void> refresh() async {
    final repo = _repo;
    if (repo == null) return;
    final context = _context;
    final TimeSettings? fresh;
    try {
      fresh = await repo.settings();
    } on TixException {
      return;
    }
    if (fresh == null || !ref.mounted || context != _context) return;
    await repo.remember(context, fresh);
    if (ref.mounted && context == _context) state = fresh;
  }

  /// Changes the reader's own [format] and [timezone] on the server: null
  /// leaves a field, empty inherits the tenant's default again.
  Future<void> set({String? format, String? timezone}) async {
    final repo = _repo;
    if (repo == null) throw StateError('no active session');
    final context = _context;
    final saved = await repo.set(format: format, timezone: timezone);
    await repo.remember(context, saved);
    if (ref.mounted && context == _context) state = saved;
  }
}

/// How dates and times are written for the active context: the server's
/// effective preference (the person's, else the tenant's, else the
/// deployment's), and the device's formats and zone for whatever it leaves
/// empty.
@Riverpod(keepAlive: true)
TixTimeStyle readerTimeStyle(Ref ref) {
  final effective = ref.watch(readerTimeProvider)?.effective;
  if (effective == null) return TixTimeStyle.device;
  return TixTimeStyle.named(effective.timeFormat, effective.timezone);
}
