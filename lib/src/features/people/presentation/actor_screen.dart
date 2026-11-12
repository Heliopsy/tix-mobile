// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/l10n/via_label.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/people/application/actor.dart';

/// One person or agent of the tenant, as tix's web actor screen: who it is,
/// the tasks assigned to it, its API tokens and SSH keys when the reader
/// holds `token:admin`, and its last audit entries when the reader holds
/// `audit:read`. What it may do is not shown here.
class ActorScreen extends ConsumerWidget {
  /// Shows the actor [actorRef], an id or a handle.
  const ActorScreen({required this.actorRef, super.key});

  /// The actor's id or handle, from the address.
  final String actorRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(actorProfileProvider(actorRef));
    final title = switch (profile.value) {
      final a? => a.handle.isNotEmpty ? a.handle : a.id,
      null => actorRef,
    };
    return TixPage(
      title: title,
      subtitle: l10n.actorSubtitle,
      body: AsyncBody(
        value: profile,
        onRetry: () => ref.invalidate(actorProfileProvider(actorRef)),
        data: (actor) => _ActorBody(actor: actor),
      ),
    );
  }
}

class _ActorBody extends ConsumerWidget {
  const _ActorBody({required this.actor});

  final Actor actor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(currentAccessProvider).value;
    final self = access != null && access.me.id == actor.id;
    final canAudit = access?.can(Scopes.auditRead) ?? false;
    final canCredentials =
        (access?.can(Scopes.tokenAdmin) ?? false) &&
        actor.kind != ActorKind.system;
    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(actorTasksProvider(actor.id))
          ..invalidate(actorTokensProvider(actor.id))
          ..invalidate(actorKeysProvider(actor.id))
          ..invalidate(actorRecentProvider(actor.id))
          ..invalidate(actorProfileProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: TixSpace.s7),
        children: [
          _About(actor: actor, self: self),
          _AssignedTasks(actor: actor),
          if (canCredentials) ...[
            _Tokens(actorId: actor.id),
            _Keys(actorId: actor.id),
          ],
          _Recent(actor: actor, canAudit: canAudit),
        ],
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About({required this.actor, required this.self});

  final Actor actor;
  final bool self;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final muted = TextStyle(color: t.muted);
    return TixSection(
      title: l10n.actorAbout,
      info: l10n.actorInfo,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TixAvatar(
                    label: actor.label,
                    seed: actor.handle.isEmpty ? actor.id : actor.handle,
                    hued: true,
                    icon: actor.kind == ActorKind.agent
                        ? Icons.smart_toy_outlined
                        : actor.kind == ActorKind.system
                        ? Icons.settings_outlined
                        : null,
                  ),
                  const SizedBox(width: TixSpace.s3),
                  Expanded(
                    child: Wrap(
                      spacing: TixSpace.s2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          actor.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TixBadge(
                          _kind(l10n, actor.kind),
                          key: const Key('actor.kind'),
                        ),
                        if (self)
                          Text(
                            l10n.actorYou,
                            key: const Key('actor.self'),
                            style: muted,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TixSpace.s3),
              TixPropertyList(
                children: [
                  TixPropertyRow(
                    label: l10n.actorHandle,
                    child: Text(
                      actor.handle.isEmpty ? '–' : actor.handle,
                      key: const Key('actor.handle'),
                    ),
                  ),
                  TixPropertyRow(
                    label: l10n.actorName,
                    child: actor.displayName.isEmpty
                        ? Text(l10n.actorNotSet, style: muted)
                        : Text(actor.displayName),
                  ),
                  TixPropertyRow(
                    label: l10n.actorId,
                    child: Row(
                      children: [
                        Flexible(
                          child: SelectableText(
                            actor.id,
                            key: const Key('actor.id'),
                            style: tixMono(context, size: TixText.sm),
                          ),
                        ),
                        TixIconButton(
                          key: const Key('actor.copyId'),
                          icon: Icons.copy,
                          tooltip: l10n.actorCopyId,
                          onPressed: () {
                            unawaited(
                              Clipboard.setData(ClipboardData(text: actor.id)),
                            );
                            showTixToast(context, l10n.copiedToClipboard);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (self) ...[
                const SizedBox(height: TixSpace.s2),
                TixButton.quiet(
                  key: const Key('actor.profile'),
                  label: l10n.actorYourProfile,
                  icon: Icons.person_outline,
                  onPressed: () => context.go(Routes.account),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _kind(AppLocalizations l10n, ActorKind? kind) => switch (kind) {
    ActorKind.agent => l10n.actorKindAgent,
    ActorKind.system => l10n.actorKindSystem,
    _ => l10n.actorKindUser,
  };
}

/// A section whose rows load: a skeleton, the error with Retry, an empty
/// line, or the rows.
class _Loaded<T> extends StatelessWidget {
  const _Loaded({
    required this.value,
    required this.onRetry,
    required this.empty,
    required this.rows,
  });

  final AsyncValue<List<T>> value;
  final VoidCallback onRetry;
  final String empty;
  final Widget Function(T item) rows;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) when value.isEmpty => Padding(
      padding: const EdgeInsets.all(TixSpace.s4),
      child: Text(empty, style: TextStyle(color: context.tix.muted)),
    ),
    AsyncData(:final value) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < value.length; i++) ...[
          if (i > 0) const Divider(),
          rows(value[i]),
        ],
      ],
    ),
    AsyncError(:final error) => ErrorState(
      error: error,
      compact: true,
      onRetry: onRetry,
    ),
    _ => const Padding(
      padding: EdgeInsets.all(TixSpace.s3),
      child: SkeletonList(rows: 2, inline: true),
    ),
  };
}

class _AssignedTasks extends ConsumerWidget {
  const _AssignedTasks({required this.actor});

  final Actor actor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = actorTasksProvider(actor.id);
    final page = ref.watch(provider);
    return TixSection(
      key: const Key('actor.tasks'),
      title: l10n.actorTasks(actor.handle.isEmpty ? actor.label : actor.handle),
      subtitle: page.value?.nextCursor == null ? null : l10n.actorTasksFirst,
      children: [
        _Loaded<Task>(
          value: page.whenData((p) => p.items),
          onRetry: () => ref.invalidate(provider),
          empty: l10n.actorTasksNone,
          rows: (task) {
            final ref = task.ref;
            final cut = ref.lastIndexOf('-');
            final project = cut > 0 ? ref.substring(0, cut) : '';
            return ListTile(
              key: Key('actor.task.$ref'),
              title: Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(ref.toUpperCase()),
              trailing: StatusPill(label: task.status),
              onTap: project.isEmpty
                  ? null
                  : () => unawaited(context.push(Routes.task(project, ref))),
            );
          },
        ),
      ],
    );
  }
}

class _Tokens extends ConsumerWidget {
  const _Tokens({required this.actorId});

  final String actorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = actorTokensProvider(actorId);
    return TixSection(
      key: const Key('actor.tokens'),
      title: l10n.actorTokens,
      children: [
        _Loaded<APIToken>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          empty: l10n.actorTokensNone,
          rows: (token) => ListTile(
            key: Key('actor.token.${token.id}'),
            title: Text(token.name),
            subtitle: Text(
              [
                token.scopes.join(' '),
                if (token.lastUsedAt case final at?)
                  l10n.actorLastUsed(formatDay(context, at))
                else
                  l10n.actorNeverUsed,
              ].join(' · '),
            ),
            trailing: token.revokedAt == null
                ? null
                : TixBadge(l10n.actorRevoked, tone: TixTone.danger),
          ),
        ),
      ],
    );
  }
}

class _Keys extends ConsumerWidget {
  const _Keys({required this.actorId});

  final String actorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = actorKeysProvider(actorId);
    return TixSection(
      key: const Key('actor.keys'),
      title: l10n.actorKeys,
      children: [
        _Loaded<SSHKey>(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          empty: l10n.actorKeysNone,
          rows: (key) => ListTile(
            key: Key('actor.key.${key.id}'),
            title: Text(key.label.isEmpty ? key.fingerprint : key.label),
            subtitle: Text(
              key.fingerprint,
              style: tixMono(context, size: TixText.xs),
            ),
            trailing: key.revokedAt == null
                ? null
                : TixBadge(l10n.actorRevoked, tone: TixTone.danger),
          ),
        ),
      ],
    );
  }
}

class _Recent extends ConsumerWidget {
  const _Recent({required this.actor, required this.canAudit});

  final Actor actor;
  final bool canAudit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = actorRecentProvider(actor.id);
    return TixSection(
      key: const Key('actor.recent'),
      title: l10n.actorRecent,
      children: [
        if (!canAudit)
          Padding(
            padding: const EdgeInsets.all(TixSpace.s4),
            child: Text(
              l10n.actorRecentNeedsAudit,
              key: const Key('actor.recent.denied'),
              style: TextStyle(color: context.tix.muted),
            ),
          )
        else
          _Loaded<AuditEntry>(
            value: ref.watch(provider),
            onRetry: () => ref.invalidate(provider),
            empty: l10n.actorRecentNone,
            rows: (entry) {
              final at = entry.occurredAt;
              return ListTile(
                key: Key('actor.audit.${entry.seq}'),
                title: Text(
                  entry.action,
                  style: tixMono(context, size: TixText.sm),
                ),
                subtitle: Text(
                  [
                    '${entry.subjectType} ${entry.subjectId}',
                    if (at != null) formatMoment(context, at),
                    ?viaLabel(l10n, entry.via),
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
      ],
    );
  }
}
