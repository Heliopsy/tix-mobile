// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/durations.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart' show PickedIcon;
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/project_admin.dart';
import 'package:tix_mobile/src/features/projects/presentation/project_delete_sheet.dart';
import 'package:tix_mobile/src/features/projects/presentation/project_form.dart';

/// A project's settings, in tix's always-visible sections: the project,
/// its appearance, claims, custom fields and the danger zone.
class ProjectSettingsScreen extends ConsumerWidget {
  /// The settings of the project [projectKey].
  const ProjectSettingsScreen({required this.projectKey, super.key});

  /// The project's key.
  final String projectKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final project = ref.watch(projectSettingsProvider(projectKey));
    final access = ref.watch(currentAccessProvider).value ?? Access.none;
    return AsyncBody(
      value: project,
      onRetry: () => ref.invalidate(projectSettingsProvider(projectKey)),
      loading: TixPage(
        title: l10n.projectSettingsTitle,
        body: const SkeletonList(),
      ),
      data: (p) => _Editor(
        key: ValueKey(p.updatedAt ?? p.key),
        project: p,
        canWrite: access.has(Scope.projectWrite),
        canImport: access.has(Scope.import),
      ),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({
    required this.project,
    required this.canWrite,
    required this.canImport,
    super.key,
  });

  final Project project;
  final bool canWrite;
  final bool canImport;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final _name = TextEditingController(text: widget.project.name);
  late final _key = TextEditingController(text: widget.project.key);
  late final _description = TextEditingController(
    text: widget.project.description,
  );
  late final _leaseDefault = TextEditingController(
    text: widget.project.leaseDefault,
  );
  late final _leaseMax = TextEditingController(text: widget.project.leaseMax);
  late String _workflow = widget.project.workflowId;
  late String _colour = widget.project.color;
  late ProjectIconValue _icon = iconValueOf(widget.project);
  PickedIcon? _image;
  Object? _error;
  var _busy = false;

  Project get _p => widget.project;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _key, _description, _leaseDefault, _leaseMax]) {
      c.addListener(_changed);
    }
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    for (final c in [_name, _key, _description, _leaseDefault, _leaseMax]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Only what changed, so the server leaves the rest alone.
  UpdateProjectInput get _input {
    String? changed(String now, String before) {
      final v = now.trim();
      return v == before ? null : v;
    }

    final before = iconValueOf(_p);
    final image = _image;
    final iconChanged = _icon != before || image != null;
    return UpdateProjectInput(
      name: changed(_name.text, _p.name),
      key: changed(_key.text, _p.key),
      description: changed(_description.text, _p.description),
      workflowKey: _workflow == _p.workflowId ? null : _workflow,
      color: _colour == _p.color ? null : _colour,
      leaseDefault: changed(_leaseDefault.text, _p.leaseDefault),
      leaseMax: changed(_leaseMax.text, _p.leaseMax),
      icon: !iconChanged
          ? null
          : switch (_icon.kind) {
              ProjectIconKind.none => '',
              ProjectIconKind.text => _icon.text,
              _ => null,
            },
      iconName: iconChanged && _icon.kind == ProjectIconKind.builtin
          ? _icon.name
          : null,
      iconFile:
          iconChanged && _icon.kind == ProjectIconKind.image && image != null
          ? ProjectIconFile(contentType: image.contentType, data: image.data)
          : null,
    );
  }

  bool get _dirty => _input != const UpdateProjectInput();

  Future<void> _save() async {
    final input = _input;
    final newKey = input.key;
    if (newKey != null && !await _confirmRekey(newKey)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await ref
          .read(projectSettingsProvider(_p.key).notifier)
          .save(input);
      if (!mounted) return;
      showTixToast(context, context.l10n.projectSaved);
      if (saved.key != _p.key) {
        context.go(Routes.projectSettings(saved.key));
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirmRekey(String newKey) async {
    final l10n = context.l10n;
    final ok = await showTixSheet<bool>(
      context,
      builder: (context) => TixSheetBody(
        title: l10n.projectRekeyTitle,
        actions: [
          TixButton.quiet(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TixButton.primary(
            key: const Key('project.rekey.ok'),
            label: l10n.projectRekeyConfirm,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.projectRekeyBody),
            const SizedBox(height: TixSpace.s3),
            Text(
              '${_p.key}-1  →  $newKey-1',
              key: const Key('project.rekey.example'),
              style: tixMono(context),
            ),
            const SizedBox(height: TixSpace.s3),
            Text(
              l10n.projectRekeyAlias(_p.key),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
    return ok ?? false;
  }

  Future<void> _archive() async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.projectArchiveTitle(_p.name),
      body: l10n.projectArchiveBody,
      action: l10n.projectArchive,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(projectSettingsProvider(_p.key).notifier).archive();
      if (mounted) showTixToast(context, l10n.projectArchived(_p.name));
    } on Object catch (e) {
      if (mounted) {
        showTixToast(context, errorDetail(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _delete() async {
    final deleted = await showProjectDeleteSheet(context, _p);
    if (deleted && mounted) context.go(Routes.projects);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final write = widget.canWrite;
    final error = _error;
    final name = _p.name.isEmpty ? _p.key : _p.name;
    final workflows = ref.watch(workflowChoicesProvider).value ?? const [];
    final inheritedLease =
        workflows
            .where((w) => w.id == _workflow || w.key == _workflow)
            .firstOrNull
            ?.definition
            ?.defaultLease ??
        '';
    return TixPage(
      title: l10n.projectSettingsTitle,
      subtitle: name,
      primaryAction: write && _dirty
          ? TixAction(
              key: const Key('project.save'),
              label: l10n.manageSaveChanges,
              icon: Icons.check,
              onPressed: _busy ? () {} : _save,
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: TixMeasure.form),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!write)
                    _Padded(
                      TixNotice(
                        l10n.projectReadOnly,
                        key: const Key('project.readOnly'),
                      ),
                    ),
                  if (error != null)
                    _Padded(
                      TixNotice(
                        errorDetail(l10n, error),
                        key: const Key('project.error'),
                        tone: TixNoticeTone.danger,
                      ),
                    ),
                  if (_p.archivedAt != null)
                    _Padded(
                      TixNotice(
                        l10n.projectIsArchived,
                        key: const Key('project.archived'),
                        tone: TixNoticeTone.warn,
                      ),
                    ),
                  TixSection(
                    title: l10n.projectSectionProject,
                    children: [
                      _Body(
                        children: [
                          TixTextField(
                            fieldKey: const Key('project.name'),
                            label: l10n.projectName,
                            controller: _name,
                            enabled: write,
                          ),
                          TixTextField(
                            fieldKey: const Key('project.key'),
                            label: l10n.projectKey,
                            controller: _key,
                            enabled: write,
                            help: l10n.projectKeyChangeHelp,
                          ),
                          TixTextField(
                            fieldKey: const Key('project.description'),
                            label: l10n.projectDescription,
                            controller: _description,
                            enabled: write,
                            maxLines: 6,
                          ),
                          WorkflowPicker(
                            value: _workflow,
                            onChanged: write
                                ? (w) => setState(
                                    () => _workflow = w.id == _p.workflowId
                                        ? _p.workflowId
                                        : w.key,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TixSection(
                    title: l10n.projectSectionAppearance,
                    children: [
                      _Body(
                        children: [
                          TixFieldLabel(l10n.projectColour),
                          TixColourPicker(
                            value: _colour,
                            onChanged: write
                                ? (c) => setState(() => _colour = c)
                                : null,
                          ),
                          TixFieldLabel(l10n.projectIcon),
                          ProjectIconPicker(
                            value: _icon,
                            names: projectIconNames,
                            onChanged: write
                                ? (v) => setState(() => _icon = v)
                                : null,
                            image: _p.iconImage.isEmpty || _image != null
                                ? null
                                : _IconImage(project: _p),
                            imageName: _image?.name,
                            onUpload: write
                                ? () async {
                                    final picked = await pickProjectIcon(ref);
                                    if (picked != null && mounted) {
                                      setState(() {
                                        _image = picked;
                                        _icon = const ProjectIconValue(
                                          kind: ProjectIconKind.image,
                                        );
                                      });
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TixSection(
                    title: l10n.projectSectionClaims,
                    info: l10n.projectClaimsInfo,
                    children: [
                      _Body(
                        children: [
                          TixTextField(
                            fieldKey: const Key('project.leaseDefault'),
                            label: l10n.projectLeaseDefault,
                            controller: _leaseDefault,
                            enabled: write,
                            hint: inheritedLease.isEmpty
                                ? l10n.manageInherited
                                : l10n.manageInheritedValue(
                                    humanDuration(l10n, inheritedLease),
                                  ),
                            help: _p.leaseDefault.isEmpty
                                ? l10n.manageDurationHelp
                                : l10n.manageDurationSaved(
                                    humanDuration(l10n, _p.leaseDefault),
                                  ),
                          ),
                          TixTextField(
                            fieldKey: const Key('project.leaseMax'),
                            label: l10n.projectLeaseMax,
                            controller: _leaseMax,
                            enabled: write,
                            hint: l10n.manageInherited,
                            help: _p.leaseMax.isEmpty
                                ? l10n.projectLeaseMaxHelp
                                : l10n.manageDurationSaved(
                                    humanDuration(l10n, _p.leaseMax),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TixSection(
                    title: l10n.fieldsTitle,
                    children: [
                      ListTile(
                        key: const Key('project.fields'),
                        leading: const Icon(Icons.tune),
                        title: Text(l10n.projectManageFields),
                        subtitle: Text(l10n.projectManageFieldsHelp),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.projectFields(_p.key)),
                      ),
                    ],
                  ),
                  if (widget.canImport)
                    TixSection(
                      title: l10n.transferImportTitle,
                      children: [
                        ListTile(
                          key: const Key('project.import'),
                          leading: const Icon(Icons.upload_file),
                          title: Text(l10n.importOpen),
                          subtitle: Text(l10n.importProjectHelp),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(Routes.importTasks(_p.key)),
                        ),
                      ],
                    ),
                  if (write)
                    TixSection(
                      title: l10n.manageDangerZone,
                      danger: true,
                      children: [
                        if (_p.archivedAt == null)
                          _DangerRow(
                            title: l10n.projectArchive,
                            body: l10n.projectArchiveHelp,
                            button: TixButton.danger(
                              key: const Key('project.archive'),
                              label: l10n.projectArchive,
                              onPressed: _archive,
                            ),
                          ),
                        _DangerRow(
                          title: l10n.projectDelete,
                          body: l10n.projectDeleteHelp,
                          button: TixButton.danger(
                            key: const Key('project.delete'),
                            label: l10n.projectDelete,
                            onPressed: _delete,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconImage extends ConsumerWidget {
  const _IconImage({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref
        .watch(projectIconProvider(project.key, project.iconImage))
        .value;
    return bytes == null
        ? const SizedBox.shrink()
        : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
  }
}

class _Padded extends StatelessWidget {
  const _Padded(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      TixSpace.s4,
      TixSpace.s4,
      TixSpace.s4,
      0,
    ),
    child: child,
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0 && c is! WorkflowPicker)
            const SizedBox(height: TixSpace.s3),
          c,
        ],
      ],
    ),
  );
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({
    required this.title,
    required this.body,
    required this.button,
  });

  final String title;
  final String body;
  final Widget button;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s4),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: TixSpace.s3,
      runSpacing: TixSpace.s2,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: TixMeasure.text),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TixSpace.s1),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        button,
      ],
    ),
  );
}
