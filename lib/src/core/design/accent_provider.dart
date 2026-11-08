// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/repositories/tenant_repository.dart';

part 'accent_provider.g.dart';

typedef _Target = ({
  String context,
  String tenant,
  String baseUrl,
  Credential credential,
});

/// The active tenant's accent: the theme remembered for the context at
/// once, then whatever the server names now. tix's default without a
/// context, and when the credential may not read its tenant.
@Riverpod(keepAlive: true)
class TenantAccent extends _$TenantAccent {
  @override
  TixAccent build() {
    final target = ref.watch(
      sessionControllerProvider.select<_Target?>((s) {
        final session = s.value;
        if (session == null || session.problem != null) return null;
        return (
          context: '${session.connection.id}.${session.connection.tenantKey}',
          tenant: session.connection.tenantKey,
          baseUrl: session.baseUrl,
          credential: session.credential,
        );
      }),
    );
    if (target == null) return TixAccent.standard;
    final repo = TenantRepository(
      ref.watch(tixApiFactoryProvider)(target.baseUrl, target.credential),
      ref.watch(keyValueStoreProvider),
    );
    if (target.tenant.isNotEmpty) {
      unawaited(_refresh(repo, target.context, target.tenant));
    }
    return TixAccent.resolve(repo.rememberedTheme(target.context));
  }

  Future<void> _refresh(
    TenantRepository repo,
    String context,
    String tenant,
  ) async {
    final String? theme;
    try {
      theme = await repo.theme(tenant);
    } on TixException {
      // Best effort: offline, the remembered accent stands.
      return;
    }
    if (theme == null || !ref.mounted) return;
    await repo.remember(context, theme);
    if (ref.mounted) state = TixAccent.resolve(theme);
  }
}
