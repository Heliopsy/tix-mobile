// SPDX-License-Identifier: AGPL-3.0-or-later

/// The inbox, personal channels and the stats the summary reads, as the
/// generated client reads them, with what the screens derive from them.
library;

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        ChannelDelivery,
        ChannelFormat,
        DeliveryStatus,
        InboxChannel,
        InboxChannelInput,
        InboxChannelUpdate,
        InboxItem,
        InboxKind,
        InboxPrefsInput,
        IssuedInboxChannel,
        StateCategory,
        Stats,
        StatsCategory;

/// The inbox kinds in the order the app lists them, strongest reason first.
const List<InboxKind> inboxKinds = [
  InboxKind.mention,
  InboxKind.assigned,
  InboxKind.comment,
  InboxKind.status,
];

/// The kind named [name], or null for one this app does not know.
InboxKind? inboxKindNamed(String name) {
  for (final k in InboxKind.values) {
    if (k.value == name) return k;
  }
  return null;
}

/// What the screens derive from an item.
extension InboxItemFacts on InboxItem {
  /// Whether the caller has read it.
  bool get read => readAt != null;

  /// The project key in [taskRef], as tix splits a reference: everything
  /// before the last hyphen. Empty when the reference is not `KEY-N`.
  String get projectKey {
    final i = taskRef.lastIndexOf('-');
    if (i <= 0 || int.tryParse(taskRef.substring(i + 1)) == null) return '';
    return taskRef.substring(0, i);
  }

  /// Whether the item leads to a task that still exists.
  bool get opensTask => !taskGone && projectKey.isNotEmpty;
}

/// A just-created channel as the list keeps it, without its secret.
extension IssuedChannelListed on IssuedInboxChannel {
  /// The channel without the secret.
  InboxChannel get listed => InboxChannel(
    id: id,
    name: name,
    url: url,
    format: format,
    kinds: kinds,
    active: active,
    actorId: actorId,
    createdAt: createdAt,
  );
}
