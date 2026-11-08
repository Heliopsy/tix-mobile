// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/audit_repository.dart';
import 'package:tix_mobile/src/data/repositories/integrations_repository.dart';
import 'package:tix_mobile/src/data/repositories/maintenance_repository.dart';

part 'integrations.g.dart';

/// Webhooks and external sync, for the active session.
@riverpod
IntegrationsRepository integrationsRepository(Ref ref) =>
    IntegrationsRepository(
      ref.watch(sessionApiProvider),
      ref.watch(responseCacheProvider),
    );

/// Retention, housekeeping and the trash, for the active session.
@riverpod
MaintenanceRepository maintenanceRepository(Ref ref) => MaintenanceRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// The audit log, for the active session.
@riverpod
AuditRepository auditRepository(Ref ref) =>
    AuditRepository(ref.watch(sessionApiProvider));
