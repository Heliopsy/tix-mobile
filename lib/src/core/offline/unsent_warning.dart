// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// [body], followed by a warning that [unsent] changes made offline are
/// lost, when any wait: what forgetting a connection asks before it goes.
String withUnsentWarning(AppLocalizations l10n, String body, int unsent) =>
    unsent == 0 ? body : '$body\n\n${l10n.syncUnsentLost(unsent)}';
