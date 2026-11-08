// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/features/integrations/application/sync.dart';

/// What to tell a person about a refused sync call: the usual message, and
/// the server's own words whenever the usual one would leave them out, so
/// an egress or file rule is read as tix wrote it.
String syncError(AppLocalizations l10n, Object error) {
  final base = errorMessage(l10n, error);
  if (error is! TixException || error.message.isEmpty) return base;
  return base.contains(error.message) ? base : '$base\n${error.message}';
}

/// The credentials stored on [source], each with its hint.
String credentialNames(SyncSource source) => [
  for (final c in source.credentials)
    if (c.hint.isEmpty) c.name else '${c.name} …${c.hint}',
].join(', ');

String _when(BuildContext context, DateTime at) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
        .add_Hm()
        .format(at.toLocal());

/// The tenant's external sync sources and their run history: register,
/// check, edit and remove sources, run one now or preview it.
class SyncScreen extends ConsumerWidget {
  /// Creates the screen.
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final newSource = TixAction(
      key: const Key('sync.new'),
      label: l10n.syncNew,
      icon: Icons.add,
      onPressed: () => editSyncSource(context),
    );
    return TixPage(
      title: l10n.syncTitle,
      subtitle: l10n.syncSubtitle,
      primaryAction: newSource,
      body: AsyncBody(
        value: ref.watch(syncSourcesProvider),
        onRetry: () => ref.invalidate(syncSourcesProvider),
        data: (sources) {
          final list = _SourceList(sources: sources, action: newSource);
          final runs = _RunHistory(
            header: context.isTwoPane
                ? SectionHeader(title: l10n.syncRuns)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      list,
                      SectionHeader(title: l10n.syncRuns),
                    ],
                  ),
          );
          if (!context.isTwoPane) return runs;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: SingleChildScrollView(child: list)),
              VerticalDivider(width: 1, color: context.tix.line),
              Expanded(flex: 2, child: runs),
            ],
          );
        },
      ),
    );
  }
}

/// Opens the source form for a new source, or for [source].
Future<void> editSyncSource(BuildContext context, [SyncSource? source]) async {
  final saved = await showTixSheet<SyncSource>(
    context,
    builder: (_) => SyncSourceForm(source: source),
  );
  if (saved != null && context.mounted) {
    showTixToast(context, context.l10n.syncSaved(saved.name));
  }
}

class _SourceList extends StatelessWidget {
  const _SourceList({required this.sources, required this.action});

  final List<SyncSource> sources;
  final TixAction action;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (sources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(TixSpace.s4),
        child: EmptyState(
          icon: Icons.sync_alt,
          title: l10n.syncEmpty,
          body: l10n.syncEmptyBody,
          action: action,
        ),
      );
    }
    return TixSection(
      title: l10n.syncSources,
      info: l10n.syncSourcesInfo,
      children: [for (final s in sources) SyncSourceCard(source: s)],
    );
  }
}

/// One sync source: its system, how its last run went, what a run would
/// still lack on the server, and its actions.
class SyncSourceCard extends ConsumerWidget {
  /// Draws [source].
  const SyncSourceCard({required this.source, super.key});

  /// The source.
  final SyncSource source;

  Future<void> _run(BuildContext context) async {
    final result = await showTixSheet<SyncResult>(
      context,
      builder: (_) => _RunSheet(source: source),
    );
    if (result == null || !context.mounted) return;
    await showTixSheet<void>(
      context,
      builder: (_) => SyncResultSheet(result: result),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.syncDeleteTitle,
      body: l10n.syncDeleteBody(source.name),
      action: l10n.syncDelete,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(syncSourcesProvider.notifier).delete(source.id);
      if (context.mounted) showTixToast(context, l10n.syncDeleted);
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, syncError(l10n, e), tone: TixTone.danger);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final theme = Theme.of(context);
    final missing = source.resolved?.missing ?? const <String>[];
    final last = source.lastRunAt;
    final (status, tone) = switch (source.lastStatus) {
      'ok' => (l10n.syncStatusOk, TixTone.ok),
      'failed' => (l10n.syncStatusFailed, TixTone.danger),
      'running' => (l10n.syncStatusRunning, TixTone.accent),
      _ => (l10n.syncStatusNever, TixTone.neutral),
    };
    return Padding(
      key: Key('sync.${source.id}'),
      padding: const EdgeInsets.all(TixSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(source.name, style: theme.textTheme.titleMedium),
              TixBadge(source.system),
              TixBadge(status, tone: tone),
            ],
          ),
          const SizedBox(height: TixSpace.s1),
          Text(
            last == null
                ? l10n.syncNeverRun
                : l10n.syncLastRun(_when(context, last)),
            style: theme.textTheme.bodySmall,
          ),
          if (source.credentials.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s1),
            Text(
              l10n.syncStoredCredentials(credentialNames(source)),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (missing.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s2),
            Container(
              key: Key('sync.${source.id}.missing'),
              width: double.infinity,
              padding: const EdgeInsets.all(TixSpace.s3),
              decoration: BoxDecoration(
                color: t.warnSoft,
                borderRadius: BorderRadius.circular(TixRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.syncMissing,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.warn,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  for (final m in missing)
                    Text('• $m', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
          const SizedBox(height: TixSpace.s3),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              TixButton(
                key: Key('sync.${source.id}.run'),
                label: l10n.syncRunNow,
                icon: Icons.play_arrow,
                size: TixButtonSize.small,
                onPressed: () => _run(context),
              ),
              TixButton.quiet(
                key: Key('sync.${source.id}.edit'),
                label: l10n.syncEdit,
                icon: Icons.edit_outlined,
                size: TixButtonSize.small,
                onPressed: () => editSyncSource(context, source),
              ),
              TixButton.danger(
                key: Key('sync.${source.id}.delete'),
                label: l10n.syncDelete,
                icon: Icons.delete_outline,
                size: TixButtonSize.small,
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RunSheet extends ConsumerStatefulWidget {
  const _RunSheet({required this.source});

  final SyncSource source;

  @override
  ConsumerState<_RunSheet> createState() => _RunSheetState();
}

class _RunSheetState extends ConsumerState<_RunSheet> {
  bool _full = false;
  bool _busy = false;
  String? _error;

  Future<void> _go({required bool dryRun}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(syncSourcesProvider.notifier)
          .run(widget.source.id, dryRun: dryRun, full: _full);
      if (mounted) Navigator.of(context).pop(result);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = syncError(context.l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return TixSheetBody(
      title: l10n.syncRunTitle(widget.source.name),
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton(
          key: const Key('sync.preview'),
          label: l10n.syncPreview,
          onPressed: _busy ? null : () => _go(dryRun: true),
        ),
        TixButton.primary(
          key: const Key('sync.go'),
          label: l10n.syncRunNow,
          busy: _busy,
          onPressed: () => _go(dryRun: false),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.syncRunBody),
          const SizedBox(height: TixSpace.s2),
          TixSwitchRow(
            key: const Key('sync.full'),
            title: l10n.syncFull,
            subtitle: l10n.syncFullHelp,
            value: _full,
            onChanged: (v) => setState(() => _full = v),
          ),
          if (error != null) _Refusal(error),
        ],
      ),
    );
  }
}

class _Refusal extends StatelessWidget {
  const _Refusal(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      key: const Key('sync.refusal'),
      margin: const EdgeInsets.only(top: TixSpace.s3),
      padding: const EdgeInsets.all(TixSpace.s3),
      decoration: BoxDecoration(
        color: t.dangerSoft,
        border: Border.all(color: t.danger),
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      child: Text(message, style: TextStyle(color: t.danger)),
    );
  }
}

/// What one sync run did, or would do.
class SyncResultSheet extends StatelessWidget {
  /// Shows [result].
  const SyncResultSheet({required this.result, super.key});

  /// The run.
  final SyncResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = result.counts();
    final theme = Theme.of(context);
    return TixSheetBody(
      title: result.dryRun ? l10n.syncPreviewTitle : l10n.syncDoneTitle,
      actions: [
        TixButton.primary(
          key: const Key('sync.result.close'),
          label: l10n.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.dryRun) Text(l10n.syncPreviewNote),
          const SizedBox(height: TixSpace.s2),
          Text(
            key: const Key('sync.result.counts'),
            l10n.syncCounts(c.created, c.updated, c.skipped, c.deleted),
            style: theme.textTheme.titleMedium,
          ),
          if (result.unmatchedUsers.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s3),
            Text(l10n.syncUnmatched, style: theme.textTheme.titleSmall),
            Text(result.unmatchedUsers.join(', ')),
          ],
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s3),
            Text(l10n.syncWarnings, style: theme.textTheme.titleSmall),
            for (final w in result.warnings) Text('• $w'),
          ],
        ],
      ),
    );
  }
}

class _RunHistory extends ConsumerWidget {
  const _RunHistory({required this.header});

  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AsyncBody(
      value: ref.watch(syncRunsProvider),
      onRetry: () => ref.invalidate(syncRunsProvider),
      data: (paged) => PagedListView(
        paged: paged,
        header: header,
        padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
        empty: EmptyState(
          icon: Icons.history,
          title: l10n.syncRunsEmpty,
          body: l10n.syncRunsEmptyBody,
        ),
        onRefresh: () => ref.refresh(syncRunsProvider.future),
        onLoadMore: () => ref.read(syncRunsProvider.notifier).loadMore(),
        itemBuilder: (context, entry) {
          final run = syncRunOf(entry);
          final at = entry.occurredAt;
          final c = run?.counts();
          return ListTile(
            key: Key('run.${entry.seq}'),
            leading: const Icon(Icons.sync),
            title: Text(
              run == null ? entry.subjectId : '${run.source} · ${run.system}',
            ),
            subtitle: Text(
              [
                if (at != null) _when(context, at),
                if (c != null)
                  l10n.syncCounts(c.created, c.updated, c.skipped, c.deleted),
                if (run != null && run.warnings.isNotEmpty)
                  l10n.syncWarningCount(run.warnings.length),
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            onTap: run == null
                ? null
                : () => showTixSheet<void>(
                    context,
                    builder: (_) => SyncResultSheet(result: run),
                  ),
          );
        },
      ),
    );
  }
}

/// The settings each system takes, as tix names them.
const syncSettings = {
  'generic': ['file', 'page_size'],
  'jira': ['url', 'project', 'query', 'page_size'],
  'openproject': ['url', 'project', 'query', 'page_size'],
};

/// Registers a sync source or edits [source]: its system and settings, a
/// mapping, and credentials that are written and never read back. Check
/// asks the server what a run would use without saving.
class SyncSourceForm extends ConsumerStatefulWidget {
  /// A form for a new source, or for [source].
  const SyncSourceForm({this.source, super.key});

  /// The source being edited, null for a new one.
  final SyncSource? source;

  @override
  ConsumerState<SyncSourceForm> createState() => _SyncSourceFormState();
}

class _SyncSourceFormState extends ConsumerState<SyncSourceForm> {
  late String _system = widget.source?.system.isNotEmpty ?? false
      ? widget.source!.system
      : 'jira';
  late final _name = TextEditingController(text: widget.source?.name ?? '');
  late final _settings = <String, TextEditingController>{
    for (final key in {...syncSettings.values.expand((k) => k)})
      key: TextEditingController(text: widget.source?.config[key] ?? ''),
  };
  late final _mapping = TextEditingController(
    text: widget.source?.mapping ?? '',
  );
  late final _mappingPath = TextEditingController(
    text: widget.source?.mappingPath ?? '',
  );
  final _token = TextEditingController();
  final _user = TextEditingController();
  final _password = TextEditingController();
  bool _clearCredentials = false;
  bool _busy = false;
  String? _error;
  SyncSource? _checked;

  @override
  void dispose() {
    for (final c in [
      _name,
      ..._settings.values,
      _mapping,
      _mappingPath,
      _token,
      _user,
      _password,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  SyncSourceInput _input() {
    String? set(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return SyncSourceInput(
      id: widget.source?.id,
      name: _name.text.trim(),
      system: _system,
      config: {
        for (final key in syncSettings[_system]!)
          if (_settings[key]!.text.trim().isNotEmpty)
            key: _settings[key]!.text.trim(),
      },
      mapping: _mapping.text.trim().isEmpty ? null : _mapping.text,
      mappingPath: set(_mappingPath),
      token: _token.text.isEmpty ? null : _token.text,
      user: set(_user),
      password: _password.text.isEmpty ? null : _password.text,
      clearCredentials: _clearCredentials ? true : null,
    );
  }

  Future<void> _submit({required bool check}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final sources = ref.read(syncSourcesProvider.notifier);
    try {
      if (check) {
        final checked = await sources.check(_input());
        if (mounted) {
          setState(() {
            _busy = false;
            _checked = checked;
          });
        }
        return;
      }
      final saved = await sources.save(_input());
      if (mounted) Navigator.of(context).pop(saved);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = syncError(context.l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final source = widget.source;
    final editing = source != null;
    final error = _error;
    final checked = _checked;
    const gap = SizedBox(height: TixSpace.s3);
    return TixSheetBody(
      title: editing ? l10n.syncEditTitle(source.name) : l10n.syncNew,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton(
          key: const Key('sync.check'),
          label: l10n.syncCheck,
          onPressed: _busy ? null : () => _submit(check: true),
        ),
        TixButton.primary(
          key: const Key('sync.save'),
          label: l10n.syncSave,
          busy: _busy,
          onPressed: () => _submit(check: false),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.syncFormIntro,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          gap,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              key: const Key('sync.system'),
              segments: [
                for (final s in syncSettings.keys)
                  ButtonSegment(value: s, label: Text(s)),
              ],
              showSelectedIcon: false,
              selected: {_system},
              onSelectionChanged: editing
                  ? null
                  : (v) => setState(() => _system = v.first),
            ),
          ),
          gap,
          TixTextField(
            fieldKey: const Key('sync.name'),
            label: l10n.syncName,
            controller: _name,
            enabled: !editing,
            help: l10n.syncNameHelp,
          ),
          for (final key in syncSettings[_system]!) ...[
            gap,
            TixTextField(
              fieldKey: Key('sync.setting.$key'),
              label: key,
              controller: _settings[key],
              keyboardType: key == 'page_size'
                  ? TextInputType.number
                  : key == 'url'
                  ? TextInputType.url
                  : null,
            ),
          ],
          gap,
          TixTextField(
            fieldKey: const Key('sync.mapping'),
            label: l10n.syncMapping,
            controller: _mapping,
            maxLines: 6,
            help: l10n.syncMappingHelp,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('sync.mappingPath'),
            label: l10n.syncMappingPath,
            controller: _mappingPath,
            help: l10n.syncMappingPathHelp,
          ),
          gap,
          SectionHeader(
            title: l10n.syncCredentials,
            subtitle: l10n.syncCredentialsHelp,
            padding: const EdgeInsets.only(top: TixSpace.s2),
          ),
          if (editing && source.credentials.isNotEmpty)
            Text(
              l10n.syncStoredCredentials(credentialNames(source)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          gap,
          TixTextField(
            fieldKey: const Key('sync.token'),
            label: l10n.syncToken,
            controller: _token,
            obscure: true,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('sync.user'),
            label: l10n.syncUser,
            controller: _user,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('sync.password'),
            label: l10n.syncPassword,
            controller: _password,
            obscure: true,
          ),
          if (editing)
            TixSwitchRow(
              key: const Key('sync.clearCredentials'),
              title: l10n.syncClearCredentials,
              value: _clearCredentials,
              onChanged: (v) => setState(() => _clearCredentials = v),
            ),
          if (error != null) _Refusal(error),
          if (checked?.resolved != null)
            SyncResolutionView(resolution: checked!.resolved!),
        ],
      ),
    );
  }
}

SyncOrigin _settingOrigin(SyncSettingOrigin s) =>
    SyncOrigin(from: s.from, detail: s.from == 'env' ? s.variable : '');

/// What a run of a source would use on the server and what it lacks, as a
/// check reports it.
class SyncResolutionView extends StatelessWidget {
  /// Shows [resolution].
  const SyncResolutionView({required this.resolution, super.key});

  /// The server's answer.
  final SyncResolution resolution;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    String origin(SyncOrigin? o) => o == null
        ? l10n.syncFromMissing
        : [
            switch (o.from) {
              'stored' => l10n.syncFromStored,
              'env' => l10n.syncFromEnv,
              'mapping_path' => l10n.syncFromMappingPath,
              'none' => l10n.syncFromNone,
              _ => l10n.syncFromMissing,
            },
            if (o.detail.isNotEmpty) o.detail,
          ].join(': ');
    final summary = resolution.summary;
    return Container(
      key: const Key('sync.resolution'),
      margin: const EdgeInsets.only(top: TixSpace.s3),
      padding: const EdgeInsets.all(TixSpace.s3),
      decoration: BoxDecoration(
        color: resolution.missing.isEmpty ? t.okSoft : t.warnSoft,
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resolution.missing.isEmpty ? l10n.syncReady : l10n.syncMissing,
            style: theme.textTheme.titleSmall,
          ),
          for (final m in resolution.missing) Text('• $m', style: small),
          const SizedBox(height: TixSpace.s2),
          Text(l10n.syncMappingFrom(origin(resolution.mapping)), style: small),
          Text(
            l10n.syncCredentialsFrom(origin(resolution.credentials)),
            style: small,
          ),
          for (final s in resolution.settings)
            Text(
              '${s.key}: ${s.value.isEmpty ? '-' : s.value} '
              '(${origin(_settingOrigin(s))})',
              style: small,
            ),
          if (summary != null) ...[
            const SizedBox(height: TixSpace.s2),
            if (summary.project.isNotEmpty)
              Text(l10n.syncSummaryProject(summary.project), style: small),
            if (summary.identity.isNotEmpty)
              Text(l10n.syncSummaryIdentity(summary.identity), style: small),
            for (final f in [...summary.fields, ...summary.statuses])
              Text(f, style: tixMono(context, size: TixText.xs)),
          ],
        ],
      ),
    );
  }
}
