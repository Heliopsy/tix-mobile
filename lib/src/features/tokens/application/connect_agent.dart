// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/agents/onboard.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/session/session.dart';

export 'package:tix_mobile/src/core/agents/onboard.dart';

part 'connect_agent.g.dart';

/// What the Connect an agent screen fills every command in with, before a
/// token is issued: the server's address, the tenant and the version it
/// runs, which pins the install commands. Null when signed out.
@riverpod
Future<OnboardTarget?> connectTarget(Ref ref) async {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null) return null;
  final me = await ref.watch(currentAccessProvider.future);
  var version = '';
  try {
    version = await ref
        .watch(authRepositoryProvider)
        .serverVersion(session.baseUrl);
  } on TixException {
    version = '';
  }
  final url = session.baseUrl.endsWith('/')
      ? session.baseUrl.substring(0, session.baseUrl.length - 1)
      : session.baseUrl;
  return OnboardTarget(
    url: url,
    tenant: me.actor.tenantKey.isNotEmpty
        ? me.actor.tenantKey
        : session.connection.tenantKey,
    version: version,
    sshHost: Uri.tryParse(url)?.host ?? '',
  );
}
