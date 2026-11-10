// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';

/// Who caused [event]: the handle tix put in the payload, else the actor's
/// id, else null for an event with no actor.
String? watchActor(TixEvent event) {
  final handle = event.payload['actor_handle'];
  if (handle is String && handle.isNotEmpty) return '@$handle';
  return event.actorId.isEmpty ? null : event.actorId;
}

/// The subject [event] is about, as a person names it: a task's ref, a
/// project's key, else the subject's id. tix's `output.EventRef`.
String watchSubject(TixEvent event) {
  for (final key in const ['ref', 'key']) {
    final v = event.payload[key];
    if (v is String && v.isNotEmpty) return v;
  }
  return event.subjectId;
}

/// Where tapping [event] goes: its task, or its project; null for anything
/// without a screen.
String? watchRoute(TixEvent event) {
  final ref = event.payload['ref'];
  if (ref is String && ref.isNotEmpty) return Routes.task(_keyOf(ref), ref);
  final key = event.payload['key'];
  if (event.subjectType == 'project' && key is String && key.isNotEmpty) {
    return Routes.project(key);
  }
  return null;
}

String _keyOf(String ref) {
  final at = ref.lastIndexOf('-');
  return at <= 0 ? ref : ref.substring(0, at);
}

/// What [event]'s payload adds beyond its subject, in a few words, as tix's
/// `output.EventDetail` writes it; empty when it adds nothing.
String watchDetail(AppLocalizations l10n, TixEvent event) {
  final p = event.payload;
  String text(String key) {
    final v = p[key];
    return v == null ? '' : '$v'.trim();
  }

  String holder(String handleKey, String idKey) {
    final h = text(handleKey);
    return h.isNotEmpty ? h : text(idKey);
  }

  final specific = switch (event.type) {
    'task.transitioned' when text('from').isNotEmpty || text('to').isNotEmpty =>
      '${text('from')} → ${text('to')}',
    'task.claimed' => [
      if (holder('claimed_by_handle', 'claimed_by') case final h
          when h.isNotEmpty && h != text('actor_handle') && h != event.actorId)
        l10n.watchFor(h),
      if (_lease(event) case final d?) l10n.watchLease(d),
    ].join(', '),
    'task.released' => switch (text('final_status').isNotEmpty
        ? text('final_status')
        : text('status')) {
      '' => '',
      final s => '→ $s',
    },
    'task.lease_expired' => [
      if (holder('previous_holder_handle', 'previous_holder') case final h
          when h.isNotEmpty)
        l10n.watchHeldBy(h),
      if (text('reverted_to') case final s when s.isNotEmpty)
        l10n.watchRevertedTo(s),
    ].join(', '),
    'task.updated' => _updated(l10n, p),
    _ => '',
  };
  if (specific.isNotEmpty) return specific;
  for (final key in const [
    'title',
    'tag',
    'depends_on',
    'name',
    'final_status',
    'status',
  ]) {
    final v = text(key);
    if (v.isNotEmpty) return v;
  }
  return '';
}

String _updated(AppLocalizations l10n, Map<String, Object?> p) {
  final fields = p['fields'];
  if (fields is List && fields.isNotEmpty) {
    return l10n.watchChanged(
      fields.map((f) => '$f'.replaceAll('_', ' ')).join(', '),
    );
  }
  if (p['restored'] == true) return l10n.watchRestored;
  if (p['deleted'] == true) return l10n.watchCommentDeleted;
  if (p.containsKey('lease_expires_at')) return l10n.watchLeaseRenewed;
  if (p['removed'] == true) {
    final tag = p['tag'];
    if (tag is String && tag.isNotEmpty) return l10n.watchTagRemoved(tag);
    final dep = p['depends_on'];
    if (dep is String && dep.isNotEmpty) {
      return l10n.watchDependencyRemoved(dep);
    }
  }
  final system = p['system'];
  if (system is String && system.isNotEmpty) {
    return l10n.watchSyncedFrom(system);
  }
  return '';
}

/// How long the lease a claim granted runs, as "30m" or "1h30m".
String? _lease(TixEvent event) {
  final raw = event.payload['lease_expires_at'];
  final at = event.occurredAt;
  final until = raw is String ? DateTime.tryParse(raw) : null;
  if (until == null || at == null) return null;
  final d = until.difference(at);
  if (d <= Duration.zero) return null;
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  if (h == 0 && m == 0) return '${s}s';
  return [
    if (h > 0) '${h}h',
    if (m > 0) '${m}m',
    if (h == 0 && s > 0) '${s}s',
  ].join();
}
