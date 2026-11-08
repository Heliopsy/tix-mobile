// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/repositories/templates_repository.dart';

part 'templates.g.dart';

/// Task templates for the active session.
@riverpod
TemplatesRepository templatesRepository(Ref ref) => TemplatesRepository(
  ref.watch(sessionApiProvider),
  ref.watch(responseCacheProvider),
);
