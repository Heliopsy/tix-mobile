// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/capability/server_features.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';

part 'tenant_icons.g.dart';

/// The uploaded icon of tenant [tenantRef] on the active connection, whose
/// digest is [digest]; a new digest reads it again.
@riverpod
Future<Uint8List> tenantIconImage(Ref ref, String tenantRef, String digest) =>
    ref.watch(adminRepositoryProvider).tenantIconImage(tenantRef);

/// Whether the active server has tenant icons, judged by its version.
@riverpod
Future<bool> tenantIconsSupported(Ref ref) async {
  final baseUrl = await ref.watch(
    sessionControllerProvider.selectAsync((s) => s?.baseUrl),
  );
  if (baseUrl == null) return false;
  final version = await ref
      .watch(authRepositoryProvider)
      .serverVersion(baseUrl);
  return supportsTenantIcons(version);
}
