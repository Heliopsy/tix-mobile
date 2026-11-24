// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

part 'sso_pending.g.dart';

/// A provider sign-in waiting in the browser, and what the connect screen
/// that started it was for.
@immutable
class PendingSso {
  /// [attempt], started at [startedAt].
  const PendingSso({
    required this.attempt,
    required this.startedAt,
    this.name = '',
    this.instanceId,
    this.replacing,
  });

  /// Reads [json], null when it is not one.
  static PendingSso? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final started = DateTime.tryParse('${json['started_at']}');
    if (json
        case {
          'base_url': final String baseUrl,
          'provider': final String provider,
          'verifier': final String verifier,
          'state': final String state,
        }
        when started != null) {
      return PendingSso(
        attempt: SsoAttempt(
          baseUrl: baseUrl,
          provider: provider,
          verifier: verifier,
          state: state,
        ),
        startedAt: started,
        name: json['name'] is String ? json['name']! as String : '',
        instanceId: json['instance_id'] as String?,
        replacing: json['replacing'] as String?,
      );
    }
    return null;
  }

  /// The attempt, verifier included.
  final SsoAttempt attempt;

  /// When the browser was opened.
  final DateTime startedAt;

  /// The name for a new instance.
  final String name;

  /// The saved instance it adds a connection to.
  final String? instanceId;

  /// The connection it signs in again.
  final String? replacing;

  /// This as JSON.
  Map<String, Object?> toJson() => {
    'base_url': attempt.baseUrl,
    'provider': attempt.provider,
    'verifier': attempt.verifier,
    'state': attempt.state,
    'started_at': startedAt.toUtc().toIso8601String(),
    'name': name,
    'instance_id': ?instanceId,
    'replacing': ?replacing,
  };
}

/// Keeps the provider sign-in under way in secure storage, so an app the
/// platform ended while the browser was open can finish it on restart.
///
/// A keychain that refuses costs only that recovery, never the sign-in, so
/// [TixErrorKind.secretStorageUnavailable] is not passed on.
class PendingSsoStore {
  /// Keeps sign-ins in [_secrets], timed by [now].
  PendingSsoStore(this._secrets, {this.now = DateTime.now});

  /// The secret the sign-in is kept under.
  static const key = 'sso.pending';

  /// How long after it started a kept sign-in is still worth finishing.
  static const lifetime = Duration(minutes: 10);

  final SecretStore _secrets;

  /// The clock a kept sign-in's age is read by.
  final DateTime Function() now;
  String? _live;

  /// Whether this run of the app has a sign-in waiting in the browser.
  bool get live => _live != null;

  /// Keeps [pending] until [clear] names its state.
  Future<void> save(PendingSso pending) async {
    _live = pending.attempt.state;
    await _quietly(() => _secrets.write(key, jsonEncode(pending.toJson())));
  }

  /// Forgets the sign-in whose state is [state], leaving a newer one kept.
  Future<void> clear(String state) async {
    if (_live != state) return;
    _live = null;
    await _quietly(() => _secrets.delete(key));
  }

  /// The sign-in an earlier run of the app kept, left in place; null when
  /// there is none or this run has its own.
  Future<PendingSso?> peek() async {
    if (live) return null;
    final raw = await _quietly(() => _secrets.read(key));
    return raw == null ? null : _decode(raw);
  }

  /// Takes the sign-in an earlier run of the app kept, null when there is
  /// none, this run has its own, or it is older than [lifetime].
  Future<PendingSso?> take() async {
    if (live) return null;
    final raw = await _quietly(() => _secrets.read(key));
    if (raw == null) return null;
    await _quietly(() => _secrets.delete(key));
    final pending = _decode(raw);
    if (pending == null) return null;
    final age = now().difference(pending.startedAt);
    return age.isNegative || age > lifetime ? null : pending;
  }

  static PendingSso? _decode(String raw) {
    try {
      return PendingSso.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  static Future<T?> _quietly<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on TixException catch (e) {
      if (e.kind != TixErrorKind.secretStorageUnavailable) rethrow;
      return null;
    }
  }
}

/// Where the provider sign-in under way is kept.
@Riverpod(keepAlive: true)
PendingSsoStore pendingSso(Ref ref) => PendingSsoStore(
  ref.watch(secretStoreProvider),
  now: ref.watch(clockProvider),
);
