// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/events/events.dart';
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

/// Where reading the reader's date settings from the server stands.
enum ReaderTimeLookup {
  /// Asked, not answered yet.
  loading,

  /// Answered, or nothing to ask without a context.
  done,

  /// The server has no `/me/time`: a tix too old to keep date preferences.
  unsupported,

  /// The request failed, such as offline or a server error.
  failed,
}

/// The active context's date settings and how the last read went.
@immutable
class ReaderTimeState {
  /// Holds [settings], read as [lookup] says.
  const ReaderTimeState({this.settings, this.lookup = ReaderTimeLookup.done});

  /// What is in force: the server's answer or what was remembered. Null
  /// leaves the device's formats in force.
  final TimeSettings? settings;

  /// How the last read from the server went.
  final ReaderTimeLookup lookup;

  @override
  bool operator ==(Object other) =>
      other is ReaderTimeState &&
      other.settings == settings &&
      other.lookup == lookup;

  @override
  int get hashCode => Object.hash(settings, lookup);
}

/// The active context's date settings: what was remembered for it at once,
/// then the server's answer, read again when the app comes back to the
/// foreground and whenever [ReaderTime.refresh] is called. tix sends no
/// event when a preference changes, so nothing on the live stream triggers
/// a read. No settings without a context, and from a server that keeps
/// none, which leaves the device's formats in force.
///
/// A connection that reaches one tenant is keyed by the connection alone,
/// as the response cache is, so `whoami` naming the tenant later does not
/// read the settings twice.
@Riverpod(keepAlive: true)
class ReaderTime extends _$ReaderTime {
  TimePrefsRepository? _repo;
  String _context = '';
  Future<void>? _reading;

  @override
  ReaderTimeState build() {
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
      return const ReaderTimeState();
    }
    final repo = TimePrefsRepository(
      ref.watch(tixApiFactoryProvider)(target.baseUrl, target.credential),
      ref.watch(keyValueStoreProvider),
    );
    _repo = repo;
    _context = target.context;
    _reading = null;
    ref.listen(appResumedProvider, (_, _) => unawaited(refresh()));
    unawaited(_read());
    return ReaderTimeState(
      settings: repo.remembered(target.context),
      lookup: ReaderTimeLookup.loading,
    );
  }

  /// Reads the settings again from the server, or waits for the read
  /// already under way; offline, what is shown stands.
  Future<void> refresh() {
    if (_repo == null) return Future.value();
    final reading = _reading;
    if (reading != null) return reading;
    state = ReaderTimeState(
      settings: state.settings,
      lookup: ReaderTimeLookup.loading,
    );
    return _read();
  }

  Future<void> _read() {
    final reading = _fetch();
    _reading = reading;
    return reading.whenComplete(() {
      if (identical(_reading, reading)) _reading = null;
    });
  }

  Future<void> _fetch() async {
    final repo = _repo;
    if (repo == null) return;
    final context = _context;
    final TimeSettings? fresh;
    try {
      fresh = await repo.settings();
    } on TixException {
      _settle(context, ReaderTimeLookup.failed);
      return;
    }
    if (fresh == null) {
      _settle(context, ReaderTimeLookup.unsupported);
      return;
    }
    if (!ref.mounted || context != _context) return;
    await repo.remember(context, fresh);
    if (ref.mounted && context == _context) {
      state = ReaderTimeState(settings: fresh);
    }
  }

  void _settle(String context, ReaderTimeLookup lookup) {
    if (!ref.mounted || context != _context) return;
    state = ReaderTimeState(settings: state.settings, lookup: lookup);
  }

  /// Changes the reader's own [format] and [timezone] on the server: null
  /// leaves a field, empty inherits the tenant's default again.
  Future<void> set({String? format, String? timezone}) async {
    final repo = _repo;
    if (repo == null) throw StateError('no active session');
    final context = _context;
    final saved = await repo.set(format: format, timezone: timezone);
    await repo.remember(context, saved);
    if (ref.mounted && context == _context) {
      state = ReaderTimeState(settings: saved);
    }
  }
}

/// How dates and times are written for the active context: the server's
/// effective preference (the person's, else the tenant's, else the
/// deployment's), and the device's formats and zone for whatever it leaves
/// empty.
@Riverpod(keepAlive: true)
TixTimeStyle readerTimeStyle(Ref ref) {
  final effective = ref.watch(readerTimeProvider).settings?.effective;
  if (effective == null) return TixTimeStyle.device;
  return TixTimeStyle.named(effective.timeFormat, effective.timezone);
}
