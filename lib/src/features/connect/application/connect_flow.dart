// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/auth.dart';
import 'package:tix_mobile/src/data/models/membership.dart';

part 'connect_flow.g.dart';

/// Where adding an instance or a connection has got to.
@immutable
sealed class ConnectStep {
  const ConnectStep();
}

/// Filling in the form.
final class ConnectForm extends ConnectStep {
  /// The form.
  const ConnectForm();
}

/// A sign-in in progress at [baseUrl].
@immutable
class SignInDraft {
  /// Creates a draft.
  const SignInDraft({
    required this.baseUrl,
    required this.email,
    this.name = '',
    this.replacing,
    this.pinned,
  });

  /// The server.
  final String baseUrl;

  /// Who is signing in.
  final String email;

  /// The name for a new instance.
  final String name;

  /// The connection a repeated sign-in keeps.
  final String? replacing;

  /// Whether the connection being replaced was pinned.
  final bool? pinned;
}

/// The server asked for a second factor code.
final class ConnectCode extends ConnectStep {
  /// Asks for a code for [ticket], or for switching to [tenant] in [session].
  const ConnectCode(
    this.draft, {
    this.ticket = '',
    this.tenant = '',
    this.session = '',
    this.pinned = false,
  });

  /// The sign-in.
  final SignInDraft draft;

  /// The login challenge's ticket, empty when a switch asked.
  final String ticket;

  /// The tenant a switch is moving to.
  final String tenant;

  /// The session being switched.
  final String session;

  /// Whether to pin once switched.
  final bool pinned;
}

/// Signed in; the person chooses a tenant and whether to pin it.
final class ConnectTenants extends ConnectStep {
  /// Offers [me]'s memberships.
  const ConnectTenants(this.draft, {required this.session, required this.me});

  /// The sign-in.
  final SignInDraft draft;

  /// The session as signed in.
  final String session;

  /// Who signed in, with their memberships.
  final Actor me;
}

/// A local database is open; the person picks or creates a tenant.
final class LocalTenants extends ConnectStep {
  /// Offers the [tenants] of [dbPath], served by [handle].
  const LocalTenants({
    required this.dbPath,
    required this.handle,
    required this.tenants,
    this.name = '',
  });

  /// The database file.
  final String dbPath;

  /// The engine serving it.
  final LocalHandle handle;

  /// Its tenants.
  final List<TenantRef> tenants;

  /// The name for the instance.
  final String name;
}

/// Saved and active.
final class ConnectDone extends ConnectStep {
  /// Done.
  const ConnectDone();
}

/// Adding an instance or a connection, one step at a time; one flow per
/// connect screen, named by [key].
@riverpod
class ConnectFlow extends _$ConnectFlow {
  LocalHandle? _pending;

  @override
  ConnectStep build(String key) {
    final engine = ref.read(localEnginesProvider).engine;
    ref.onDispose(() {
      final pending = _pending;
      if (pending != null) unawaited(engine.stop(pending));
    });
    return const ConnectForm();
  }

  /// Back to the form, stopping an engine opened only for this flow.
  Future<void> restart() async {
    final pending = _pending;
    _pending = null;
    if (pending != null) {
      await ref.read(localEnginesProvider).engine.stop(pending);
    }
    state = const ConnectForm();
  }

  /// Connects with an API token.
  Future<void> token({
    required String url,
    required String token,
    String name = '',
    String? instanceId,
  }) async {
    await ref
        .read(sessionControllerProvider.notifier)
        .connect(url: url, token: token, name: name, instanceId: instanceId);
    state = const ConnectDone();
  }

  /// Signs in with [email] and [password], at [url] or at the instance of
  /// [instanceId] or of the connection [replacing].
  Future<void> signIn({
    required String url,
    required String email,
    required String password,
    String name = '',
    String? instanceId,
    String? replacing,
  }) async {
    final repo = ref.read(instancesRepositoryProvider);
    final auth = ref.read(authRepositoryProvider);
    final old = replacing == null ? null : repo.connection(replacing);
    final instance = repo.instance(old?.instanceId ?? instanceId ?? '');
    final baseUrl = await auth.checkServer(instance?.baseUrl ?? url);
    final result = await auth.login(baseUrl, email: email, password: password);
    await _signedIn(
      SignInDraft(
        baseUrl: baseUrl,
        email: email.trim(),
        name: name,
        replacing: old?.id,
        pinned: old?.pinned,
      ),
      result,
    );
  }

  /// Sends the second factor [code] the server asked for.
  Future<void> code(String code) async {
    final step = state;
    if (step is! ConnectCode) return;
    if (step.ticket.isNotEmpty) {
      final result = await ref
          .read(authRepositoryProvider)
          .loginCode(step.draft.baseUrl, ticket: step.ticket, code: code);
      await _signedIn(step.draft, result);
      return;
    }
    if (code.trim().isEmpty) {
      throw const TixException(TixErrorKind.codeRequired);
    }
    await _switchAndSave(
      step.draft,
      session: step.session,
      tenant: step.tenant,
      pinned: step.pinned,
      code: code,
    );
  }

  /// Opens [tenant], pinned to it or switchable.
  Future<void> chooseTenant(Membership tenant, {required bool pinned}) async {
    final step = state;
    if (step is! ConnectTenants) return;
    if (tenant.tenantKey == step.me.tenantKey) {
      await _save(step.draft, step.session, step.me, pinned: pinned);
      return;
    }
    await _switchAndSave(
      step.draft,
      session: step.session,
      tenant: tenant.tenantKey,
      pinned: pinned,
    );
  }

  Future<void> _signedIn(SignInDraft draft, LoginResult result) async {
    final session = result.session;
    if (session == null) {
      state = ConnectCode(draft, ticket: result.challenge?.ticket ?? '');
      return;
    }
    final me = await ref
        .read(authRepositoryProvider)
        .whoami(draft.baseUrl, SessionCredential(session.token));
    if (me.memberships.length > 1) {
      state = ConnectTenants(draft, session: session.token, me: me);
      return;
    }
    await _save(draft, session.token, me, pinned: draft.pinned ?? true);
  }

  Future<void> _switchAndSave(
    SignInDraft draft, {
    required String session,
    required String tenant,
    required bool pinned,
    String? code,
  }) async {
    final auth = ref.read(authRepositoryProvider);
    final result = await auth.switchTenant(
      draft.baseUrl,
      session: session,
      tenant: tenant,
      code: code,
    );
    final next = result.session;
    if (next == null) {
      state = ConnectCode(
        draft,
        tenant: tenant,
        session: session,
        pinned: pinned,
      );
      return;
    }
    final me = await auth.whoami(draft.baseUrl, SessionCredential(next.token));
    await _save(draft, next.token, me, pinned: pinned);
  }

  Future<void> _save(
    SignInDraft draft,
    String session,
    Actor me, {
    required bool pinned,
  }) async {
    await ref
        .read(sessionControllerProvider.notifier)
        .saveSignIn(
          baseUrl: draft.baseUrl,
          email: draft.email,
          session: session,
          me: me,
          pinned: pinned,
          name: draft.name,
          replacing: draft.replacing,
        );
    state = const ConnectDone();
  }

  /// Opens the database at [path], creating it when [create], and lists its
  /// tenants. With [instanceId] it opens that saved local instance.
  Future<void> openLocal({
    String path = '',
    bool create = false,
    String name = '',
    String? instanceId,
  }) async {
    final engines = ref.read(localEnginesProvider);
    final saved = ref
        .read(instancesRepositoryProvider)
        .instance(instanceId ?? '');
    final LocalHandle handle;
    if (saved != null) {
      handle = await engines.ensure(saved);
    } else {
      handle = await engines.engine.start(dbPath: path, initIfMissing: create);
      _pending = handle;
    }
    final tenants = await engines.engine.tenants(handle);
    state = LocalTenants(
      dbPath: saved?.dbPath ?? path,
      handle: handle,
      tenants: tenants,
      name: saved?.name ?? name,
    );
  }

  /// Mints a token for [tenant] of the open database and saves it.
  Future<void> openLocalTenant(TenantRef tenant) async {
    final step = state;
    if (step is! LocalTenants) return;
    final engine = ref.read(localEnginesProvider).engine;
    final token = await engine.token(
      step.handle,
      tenant: tenant.key,
      name: 'tix-mobile',
    );
    await ref
        .read(sessionControllerProvider.notifier)
        .saveLocal(
          dbPath: step.dbPath,
          handle: step.handle,
          tenant: tenant,
          token: token,
          name: step.name,
        );
    _pending = null;
    state = const ConnectDone();
  }

  /// Creates the tenant [key] named [name] in the open database and opens it.
  Future<void> createLocalTenant({
    required String key,
    String name = '',
  }) async {
    final step = state;
    if (step is! LocalTenants) return;
    if (key.trim().isEmpty) {
      throw const TixException(TixErrorKind.tenantRequired);
    }
    final tenant = await ref
        .read(localEnginesProvider)
        .engine
        .createTenant(step.handle, key: key.trim(), name: name.trim());
    await openLocalTenant(tenant);
  }
}
