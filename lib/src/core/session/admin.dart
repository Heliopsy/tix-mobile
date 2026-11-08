// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/admin_repository.dart';
import 'package:tix_mobile/src/data/repositories/security_repository.dart';

export 'package:tix_mobile/src/data/repositories/admin_repository.dart';
export 'package:tix_mobile/src/data/repositories/security_repository.dart';

part 'admin.g.dart';

/// Tenant and server administration for the active session.
@riverpod
AdminRepository adminRepository(Ref ref) => AdminRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);

/// The signed-in person's second factor and SSH keys, for the active
/// session.
@riverpod
SecurityRepository securityRepository(Ref ref) =>
    SecurityRepository(ref.watch(sessionApiProvider));
