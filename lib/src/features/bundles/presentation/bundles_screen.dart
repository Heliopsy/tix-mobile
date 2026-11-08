// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/bundles/application/bundles.dart';

/// A bundle component kind's name.
String bundleKindLabel(AppLocalizations l10n, ComponentKind? kind) =>
    switch (kind) {
      ComponentKind.workflow => l10n.bundleKindWorkflow,
      ComponentKind.fieldDef => l10n.bundleKindField,
      ComponentKind.tag => l10n.bundleKindTag,
      ComponentKind.projectTemplate => l10n.bundleKindProject,
      ComponentKind.webhook => l10n.bundleKindWebhook,
      null => '—',
    };

/// What an import did, or would do, to one component.
String bundleActionLabel(AppLocalizations l10n, ComponentAction? action) =>
    switch (action) {
      ComponentAction.created => l10n.bundleActionCreate,
      ComponentAction.updated => l10n.bundleActionReplace,
      ComponentAction.renamed => l10n.bundleActionRename,
      ComponentAction.skipped => l10n.bundleActionSkip,
      null => '—',
    };

/// Workflows, field definitions, tags, project templates and webhooks out of
/// this tenant as one bundle file, and a bundle into it after a preview.
class BundlesScreen extends ConsumerWidget {
  /// Creates the screen.
  const BundlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    return TixPage(
      title: l10n.bundlesTitle,
      subtitle: session?.connection.tenantLabel.isNotEmpty ?? false
          ? session!.connection.tenantLabel
          : session?.instance.name,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: const [_ExportSection(), _ImportSection()],
      ),
    );
  }
}

class _ExportSection extends ConsumerStatefulWidget {
  const _ExportSection();

  @override
  ConsumerState<_ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<_ExportSection> {
  final _kinds = <ComponentKind>{};
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final origin = originOf(context);
    setState(() => _busy = true);
    try {
      final file = await ref
          .read(bundleTransferProvider.notifier)
          .export(kinds: _kinds, name: _name.text);
      final saved = await ref
          .read(attachmentsProvider)
          .saveBytes(file.name, file.bytes, bundleMimeType, origin: origin);
      if (saved && mounted) {
        showTixToast(context, l10n.bundleExported(file.name));
      }
    } on Object catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSection(
      title: l10n.bundleExportTitle,
      subtitle: l10n.bundleExportSubtitle,
      info: l10n.bundleExportInfo,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s1,
                children: [
                  for (final k in bundleKinds)
                    TixFilterChip(
                      key: Key('bundle.kind.${k.value}'),
                      label: bundleKindLabel(l10n, k),
                      selected: _kinds.contains(k),
                      onSelected: (on) =>
                          setState(() => on ? _kinds.add(k) : _kinds.remove(k)),
                    ),
                ],
              ),
              const SizedBox(height: TixSpace.s1),
              Text(
                _kinds.isEmpty ? l10n.bundleKindsAll : l10n.bundleKindsSome,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: TixSpace.s3),
              TixTextField(
                fieldKey: const Key('bundle.name'),
                label: l10n.bundleName,
                controller: _name,
                help: l10n.bundleNameHelp,
              ),
              const SizedBox(height: TixSpace.s3),
              TixButton.primary(
                key: const Key('bundle.export'),
                label: l10n.bundleExport,
                icon: Icons.download,
                onPressed: _busy ? null : _export,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImportSection extends ConsumerStatefulWidget {
  const _ImportSection();

  @override
  ConsumerState<_ImportSection> createState() => _ImportSectionState();
}

class _ImportSectionState extends ConsumerState<_ImportSection> {
  final _project = TextEditingController();
  PickedFile? _file;
  BundleCollision? _collision;
  BundleResult? _result;
  Object? _error;
  bool _busy = false;

  @override
  void dispose() {
    _project.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await ref.read(attachmentsProvider).pickFile();
    if (picked == null || !mounted) return;
    setState(() {
      _file = picked;
      _result = null;
      _error = null;
    });
    await _run(preview: true);
  }

  Future<void> _run({required bool preview}) async {
    final file = _file;
    if (file == null) return;
    final l10n = context.l10n;
    if (!preview && _collision == BundleCollision.replace) {
      final ok = await confirmDestructive(
        context,
        title: l10n.bundleImport,
        body: l10n.bundleReplaceBody,
        action: l10n.bundleImport,
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
          .import(
            utf8.decode(file.bytes, allowMalformed: true),
            preview: preview,
            onCollision: _collision,
            projectRef: _project.text,
          );
      if (!mounted) return;
      setState(() => _result = result);
      if (!preview) showTixToast(context, l10n.bundleImported);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final file = _file;
    final result = _result;
    final error = _error;
    return TixSection(
      title: l10n.bundleImportTitle,
      subtitle: l10n.bundleImportSubtitle,
      info: l10n.bundleImportInfo,
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
                    key: const Key('bundle.pick'),
                    label: l10n.bundlePick,
                    icon: Icons.upload_file,
                    onPressed: _busy ? null : _pick,
                  ),
                  if (file != null) Text(file.name, style: tixMono(context)),
                ],
              ),
              const SizedBox(height: TixSpace.s3),
              Text(
                l10n.bundleCollision,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: TixSpace.s1),
              TixChoices<BundleCollision?>(
                key: const Key('bundle.collision'),
                choices: [
                  TixChoice(null, l10n.bundleCollisionAsk),
                  TixChoice(BundleCollision.skip, l10n.bundleCollisionSkip),
                  TixChoice(BundleCollision.rename, l10n.bundleCollisionRename),
                  TixChoice(
                    BundleCollision.replace,
                    l10n.bundleCollisionReplace,
                  ),
                ],
                selected: _collision,
                onSelected: (c) => setState(() {
                  _collision = c;
                  _result = null;
                }),
              ),
              const SizedBox(height: TixSpace.s3),
              TixTextField(
                fieldKey: const Key('bundle.project'),
                label: l10n.bundleProject,
                controller: _project,
                help: l10n.bundleProjectHelp,
                onChanged: (_) => setState(() => _result = null),
              ),
              if (error != null) ...[
                const SizedBox(height: TixSpace.s3),
                Text(
                  errorMessage(l10n, error),
                  key: const Key('bundle.error'),
                  style: TextStyle(color: context.tix.danger),
                ),
              ],
              if (result != null) ...[
                const SizedBox(height: TixSpace.s3),
                _Outcomes(result: result),
              ],
              const SizedBox(height: TixSpace.s3),
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  TixButton.quiet(
                    key: const Key('bundle.preview'),
                    label: l10n.bundlePreview,
                    icon: Icons.visibility_outlined,
                    onPressed: _busy || file == null
                        ? null
                        : () => _run(preview: true),
                  ),
                  TixButton.primary(
                    key: const Key('bundle.import'),
                    label: l10n.bundleImport,
                    icon: Icons.upload,
                    onPressed:
                        _busy ||
                            file == null ||
                            result == null ||
                            !result.preview
                        ? null
                        : () => _run(preview: false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Outcomes extends StatelessWidget {
  const _Outcomes({required this.result});

  final BundleResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final small = Theme.of(context).textTheme.bodySmall;
    return Column(
      key: Key(result.preview ? 'bundle.plan' : 'bundle.done'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.preview ? l10n.bundlePlan : l10n.bundleDone,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (result.bundleName.isNotEmpty) Text(result.bundleName, style: small),
        const SizedBox(height: TixSpace.s1),
        if (result.outcomes.isEmpty) Text(l10n.bundleEmpty, style: small),
        for (final o in result.outcomes)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              [
                bundleActionLabel(l10n, o.action),
                bundleKindLabel(l10n, o.kind),
                if (o.newKey.isNotEmpty) '${o.key} → ${o.newKey}' else o.key,
                if (o.reason.isNotEmpty) o.reason,
              ].join(' · '),
            ),
          ),
        for (final w in result.warnings)
          Text(w, style: small?.copyWith(color: context.tix.warn)),
      ],
    );
  }
}

/// Where [context]'s widget is on screen, to anchor a share sheet on
/// tablets.
Rect? originOf(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  return box == null || !box.hasSize
      ? null
      : box.localToGlobal(Offset.zero) & box.size;
}
