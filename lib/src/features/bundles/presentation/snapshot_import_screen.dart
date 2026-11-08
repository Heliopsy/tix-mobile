// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/bundles/application/bundles.dart';

/// A snapshot written by `tix export` read into this tenant: a dry run
/// first, which counts what would change, then the import.
class SnapshotImportScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SnapshotImportScreen({super.key});

  @override
  ConsumerState<SnapshotImportScreen> createState() =>
      _SnapshotImportScreenState();
}

class _SnapshotImportScreenState extends ConsumerState<SnapshotImportScreen> {
  PickedFile? _file;
  SnapshotImportMode _mode = SnapshotImportMode.merge;
  ImportResult? _result;
  Object? _error;
  bool _busy = false;

  Future<void> _pick() async {
    final picked = await ref.read(attachmentsProvider).pickFile();
    if (picked == null || !mounted) return;
    setState(() {
      _file = picked;
      _result = null;
      _error = null;
    });
    await _run(dryRun: true);
  }

  Future<void> _run({required bool dryRun}) async {
    final file = _file;
    if (file == null) return;
    final l10n = context.l10n;
    if (!dryRun) {
      final ok = await confirmDestructive(
        context,
        title: l10n.snapshotImport,
        body: _mode == SnapshotImportMode.replace
            ? l10n.snapshotReplaceBody
            : l10n.snapshotMergeBody,
        action: l10n.snapshotImport,
      );
      if (!ok || !mounted) return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(bundleTransferProvider.notifier)
          .importSnapshot(
            utf8.decode(file.bytes, allowMalformed: true),
            mode: _mode,
            dryRun: dryRun,
          );
      if (!mounted) return;
      setState(() => _result = result);
      if (!dryRun) showTixToast(context, l10n.snapshotImported);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final file = _file;
    final result = _result;
    final error = _error;
    return TixPage(
      title: l10n.snapshotTitle,
      subtitle: session?.connection.tenantLabel.isNotEmpty ?? false
          ? session!.connection.tenantLabel
          : session?.instance.name,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: [
          TixSection(
            title: l10n.snapshotFileTitle,
            subtitle: l10n.snapshotFileSubtitle,
            info: l10n.snapshotInfo,
            children: [
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: TixSpace.s3,
                      runSpacing: TixSpace.s2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TixButton.quiet(
                          key: const Key('snapshot.pick'),
                          label: l10n.snapshotPick,
                          icon: Icons.upload_file,
                          onPressed: _busy ? null : _pick,
                        ),
                        if (file != null)
                          Text(file.name, style: tixMono(context)),
                      ],
                    ),
                    const SizedBox(height: TixSpace.s3),
                    TixChoices<SnapshotImportMode>(
                      key: const Key('snapshot.mode'),
                      choices: [
                        TixChoice(SnapshotImportMode.merge, l10n.snapshotMerge),
                        TixChoice(
                          SnapshotImportMode.replace,
                          l10n.snapshotReplace,
                        ),
                      ],
                      selected: _mode,
                      onSelected: (m) => setState(() {
                        _mode = m;
                        _result = null;
                      }),
                    ),
                    const SizedBox(height: TixSpace.s1),
                    Text(
                      _mode == SnapshotImportMode.merge
                          ? l10n.snapshotMergeHelp
                          : l10n.snapshotReplaceHelp,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: TixSpace.s3),
                      Text(
                        errorMessage(l10n, error),
                        key: const Key('snapshot.error'),
                        style: TextStyle(color: context.tix.danger),
                      ),
                    ],
                    if (result != null) ...[
                      const SizedBox(height: TixSpace.s3),
                      _Counts(result: result),
                    ],
                    const SizedBox(height: TixSpace.s3),
                    Wrap(
                      spacing: TixSpace.s2,
                      runSpacing: TixSpace.s2,
                      children: [
                        TixButton.quiet(
                          key: const Key('snapshot.dryRun'),
                          label: l10n.snapshotDryRun,
                          icon: Icons.visibility_outlined,
                          onPressed: _busy || file == null
                              ? null
                              : () => _run(dryRun: true),
                        ),
                        if (_mode == SnapshotImportMode.replace)
                          TixButton.danger(
                            key: const Key('snapshot.import'),
                            label: l10n.snapshotImport,
                            icon: Icons.upload,
                            onPressed: _canImport(result)
                                ? () => _run(dryRun: false)
                                : null,
                          )
                        else
                          TixButton.primary(
                            key: const Key('snapshot.import'),
                            label: l10n.snapshotImport,
                            icon: Icons.upload,
                            onPressed: _canImport(result)
                                ? () => _run(dryRun: false)
                                : null,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canImport(ImportResult? result) =>
      !_busy && _file != null && result != null && result.dryRun;
}

class _Counts extends StatelessWidget {
  const _Counts({required this.result});

  final ImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final small = Theme.of(context).textTheme.bodySmall;
    String line(String label, Map<String, int>? counts) {
      final parts = [
        for (final MapEntry(:key, :value) in (counts ?? const {}).entries)
          if (value > 0) '$key $value',
      ];
      return '$label: ${parts.isEmpty ? '0' : parts.join(', ')}';
    }

    return Column(
      key: Key(result.dryRun ? 'snapshot.plan' : 'snapshot.done'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.dryRun ? l10n.snapshotPlan : l10n.snapshotDone,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(line(l10n.snapshotCreated, result.created)),
        Text(line(l10n.snapshotUpdated, result.updated)),
        Text(line(l10n.snapshotDeleted, result.deleted)),
        Text(line(l10n.snapshotSkipped, result.skipped)),
        for (final w in result.warnings)
          Text(w, style: small?.copyWith(color: context.tix.warn)),
      ],
    );
  }
}
