// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';

/// Opens the app's quick add for [projectKey]. The sheet itself belongs to
/// the quick-action host the router mounts around the signed-in screens.
Future<void> showQuickAdd(BuildContext context, String projectKey) async =>
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(quickAddDraftsProvider.notifier).open(project: projectKey);
