// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/models/server_context.dart';

/// Saved servers in settings, their tokens in secure storage.
class ContextsRepository {
  /// Keeps contexts in [_settings] and tokens in [_secrets].
  ContextsRepository(this._settings, this._secrets);

  static const _listKey = 'contexts';
  static const _activeKey = 'contexts.active';

  final KeyValueStore _settings;
  final SecretStore _secrets;

  static String _tokenKey(String id) => 'token.$id';

  /// Every saved context, in the order they were added.
  List<ServerContext> contexts() {
    final raw = _settings.read(_listKey);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [
      for (final e in list) ServerContext.fromJson(e as Map<String, dynamic>),
    ];
  }

  /// The active context, null when none is saved or chosen.
  ServerContext? active() {
    final id = _settings.read(_activeKey);
    for (final c in contexts()) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// The token saved for the context [id].
  Future<String?> token(String id) => _secrets.read(_tokenKey(id));

  /// Saves [context] with [token], replacing one of the same id, and makes it
  /// the active one.
  Future<void> save(ServerContext context, String token) async {
    await _secrets.write(_tokenKey(context.id), token);
    final list = [
      for (final c in contexts())
        if (c.id != context.id) c,
      context,
    ];
    await _writeList(list);
    await _settings.write(_activeKey, context.id);
  }

  /// Makes the context [id] the active one.
  Future<void> activate(String id) => _settings.write(_activeKey, id);

  /// Forgets the context [id] and its token. When it was active, the first
  /// remaining context becomes active.
  Future<void> remove(String id) async {
    await _secrets.delete(_tokenKey(id));
    final rest = [
      for (final c in contexts())
        if (c.id != id) c,
    ];
    await _writeList(rest);
    if (_settings.read(_activeKey) == id) {
      if (rest.isEmpty) {
        await _settings.delete(_activeKey);
      } else {
        await _settings.write(_activeKey, rest.first.id);
      }
    }
  }

  Future<void> _writeList(List<ServerContext> list) =>
      _settings.write(_listKey, jsonEncode([for (final c in list) c.toJson()]));
}
