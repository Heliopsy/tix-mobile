// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/session/signed_out.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/core/update/update_notice.dart' show storedL10n;
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';
import 'package:tix_mobile/src/data/repositories/auth_repository.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';

/// The credential [connection] presents with [secret].
Credential credentialOf(Connection connection, String secret) =>
    switch (connection.kind) {
      ConnectionKind.token => BearerCredential(secret),
      ConnectionKind.signIn => SessionCredential(secret),
    };

/// Decides when a server has refused a connection's credential and records
/// it. The app and the widgets' headless run share it, so both confirm the
/// same way and leave the same state behind.
class RefusedCredentials {
  /// Records through [instances], confirming with [auth].
  RefusedCredentials({
    required this.instances,
    required this.auth,
    required this.jobs,
    required this.notes,
    required this.store,
    required this.now,
  });

  /// The saved connections and their secrets.
  final InstancesRepository instances;

  /// Asks `whoami`.
  final AuthRepository auth;

  /// The connections' running work.
  final ConnectionJobs jobs;

  /// System notifications.
  final LocalNotifier notes;

  /// Preferences, for the notification's language.
  final KeyValueStore store;

  /// The clock.
  final DateTime Function() now;

  /// Whether [baseUrl] refuses [credential] on `whoami` too. tix has no
  /// renewal route and a `whoami` it accepts renews a live session, so a
  /// credential it accepts was refused for something else, such as a wrong
  /// code. Anything but a `401` is not a refusal.
  Future<bool> confirmed(String baseUrl, Credential credential) async {
    try {
      await auth.whoami(baseUrl, credential);
      return false;
    } on TixException catch (e) {
      return e.status == 401;
    }
  }

  /// Cancels the work of [connection], marks it refused and, for a sign-in,
  /// deletes the session; a token is kept. Notifies when allowed. Does
  /// nothing when it is already refused or holds another secret than
  /// [credential] by now. Whether it recorded the refusal.
  Future<bool> record(Connection connection, Credential credential) async {
    final current = instances.connection(connection.id);
    if (current == null || current.refused) return false;
    await jobs.cancel(current.id);
    if (await instances.secret(current) != credential.secret) return false;
    await instances.update(current.copyWith(refusedAt: now()));
    if (current.kind == ConnectionKind.signIn) {
      await instances.deleteSecret(current);
    }
    log('${current.kind.name} of ${current.id} refused');
    final instance = instances.instance(current.instanceId);
    if (instance != null) unawaited(_note(current, instance));
    return true;
  }

  /// Confirms and records a refusal of the stored credential of the remote
  /// [connection], as the widgets do after a `401`. Whether it recorded one.
  Future<bool> check(Connection connection) async {
    final instance = instances.instance(connection.instanceId);
    if (instance == null || instance.kind != InstanceKind.remote) return false;
    final String? secret;
    try {
      secret = await instances.secret(connection);
    } on Exception catch (e) {
      log('refusal: credential unreadable: ${e.runtimeType}');
      return false;
    }
    if (secret == null || secret.isEmpty) return false;
    final credential = credentialOf(connection, secret);
    if (!await confirmed(instance.baseUrl, credential)) return false;
    return await record(connection, credential);
  }

  Future<void> _note(Connection connection, Instance instance) async {
    try {
      if (!await notes.allowed()) return;
      final l10n = storedL10n(store);
      await notes.show(switch (connection.kind) {
        ConnectionKind.signIn => signedOutNote(l10n, instance.name),
        ConnectionKind.token => tokenRefusedNote(l10n, instance.name),
      });
    } on Object catch (e) {
      log('refusal: notification failed: ${e.runtimeType}');
    }
  }
}
