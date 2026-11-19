// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';

/// What a tap on the signed-out notification hands back.
const signedOutNotePayload = 'tix-signed-out';

/// The signed-out notification's id: one at a time, the latest replacing it.
final int signedOutNoteId = stableNoteId(signedOutNotePayload);

/// The notification saying the server [server] ended the session.
LocalNote signedOutNote(AppLocalizations l10n, String server) => LocalNote(
  id: signedOutNoteId,
  title: l10n.signedOutNoteTitle(server),
  body: l10n.signedOutNoteBody,
  payload: signedOutNotePayload,
  channel: NoteChannel.account,
);

/// The notification saying the server [server] refused the saved API token.
/// It takes the signed-out notification's place: both ask for a credential.
LocalNote tokenRefusedNote(AppLocalizations l10n, String server) => LocalNote(
  id: signedOutNoteId,
  title: l10n.tokenRefusedNoteTitle(server),
  body: l10n.tokenRefusedNoteBody,
  payload: signedOutNotePayload,
  channel: NoteChannel.account,
);
