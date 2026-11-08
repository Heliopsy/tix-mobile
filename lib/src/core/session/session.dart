// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/server_context.dart';
import 'package:tix_mobile/src/data/repositories/contexts_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';

part 'session.g.dart';

/// The saved servers.
@Riverpod(keepAlive: true)
ContextsRepository contextsRepository(Ref ref) => ContextsRepository(
  ref.watch(keyValueStoreProvider),
  ref.watch(secretStoreProvider),
);

/// The active server and its token.
@immutable
class Session {
  /// Signs in to [context] with [token].
  const Session({required this.context, required this.token});

  /// The server.
  final ServerContext context;

  /// The API token.
  final String token;
}

/// The active session: null until someone connects.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<Session?> build() async {
    final repo = ref.watch(contextsRepositoryProvider);
    final active = repo.active();
    if (active == null) return null;
    final token = await repo.token(active.id);
    if (token == null || token.isEmpty) return null;
    return Session(context: active, token: token);
  }

  /// Checks that [url] is a tix server that accepts [token], then saves it
  /// as a context and makes it active. Throws a [TixException] otherwise.
  Future<void> connect({
    required String url,
    required String token,
    String name = '',
  }) async {
    final baseUrl = normalizeServerUrl(url);
    if (baseUrl == null) throw const TixException(TixErrorKind.badUrl);
    final secret = token.trim();
    if (secret.isEmpty) throw const TixException(TixErrorKind.tokenRequired);
    final build = ref.read(tixApiFactoryProvider);
    try {
      await build(baseUrl, null).health();
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.notFound) {
        throw TixException(TixErrorKind.notTix, status: e.status);
      }
      rethrow;
    }
    final me = await build(baseUrl, secret).whoami();
    final repo = ref.read(contextsRepositoryProvider);
    final same = repo.contexts().where(
      (c) => c.baseUrl == baseUrl && c.handle == me.handle,
    );
    final context = ServerContext(
      id: same.isEmpty ? _newId() : same.first.id,
      name: name.trim().isEmpty ? Uri.parse(baseUrl).host : name.trim(),
      baseUrl: baseUrl,
      handle: me.handle,
    );
    await repo.save(context, secret);
    state = AsyncData(Session(context: context, token: secret));
  }

  /// Makes the saved context [id] active.
  Future<void> switchTo(String id) async {
    await ref.read(contextsRepositoryProvider).activate(id);
    ref.invalidateSelf();
    await future;
  }

  /// Forgets the active context and its token, falling back to another
  /// saved context if there is one.
  Future<void> signOut() async {
    final current = state.value;
    if (current == null) return;
    await ref.read(contextsRepositoryProvider).remove(current.context.id);
    ref.invalidateSelf();
    await future;
  }

  static String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}

/// Every saved context, refreshed whenever the session changes.
@riverpod
List<ServerContext> savedContexts(Ref ref) {
  ref.watch(sessionControllerProvider);
  return ref.watch(contextsRepositoryProvider).contexts();
}

/// The API client for the active session.
@riverpod
TixApi sessionApi(Ref ref) {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null) throw StateError('no active session');
  return ref.watch(tixApiFactoryProvider)(
    session.context.baseUrl,
    session.token,
  );
}

/// Projects and tasks on the active server; rebuilt when the session changes.
@riverpod
TasksRepository tasksRepository(Ref ref) =>
    TasksRepository(ref.watch(sessionApiProvider));
