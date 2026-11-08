// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

/// The icon [p] wears, as the icon picker edits it.
ProjectIconValue iconValueOf(Project p) => p.iconImage.isNotEmpty
    ? const ProjectIconValue(kind: ProjectIconKind.image)
    : p.iconName.isNotEmpty
    ? ProjectIconValue(kind: ProjectIconKind.builtin, name: p.iconName)
    : p.icon.isNotEmpty
    ? ProjectIconValue(kind: ProjectIconKind.text, text: p.icon)
    : const ProjectIconValue();

/// The image a person picked for a project's icon.
typedef PickedIcon = ({String name, String contentType, String data});

/// Asks for an image file for a project icon; null when cancelled.
Future<PickedIcon?> pickProjectIcon(WidgetRef ref) async {
  final file = await ref.read(attachmentsProvider).pickFile();
  if (file == null) return null;
  return (
    name: file.name,
    contentType: file.mimeType,
    data: base64Encode(file.bytes),
  );
}

/// The workflow picker of a project form: the tenant's workflows when the
/// credential may read them, else nothing (tix then keeps or picks its
/// builtin workflow).
class WorkflowPicker extends ConsumerWidget {
  /// A picker showing [value], a workflow key or id.
  const WorkflowPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The chosen workflow's key or id; empty for the builtin one.
  final String value;

  /// Called with the chosen workflow; null disables the picker.
  final ValueChanged<Workflow>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value ?? Access.none;
    if (!access.has(Scope.workflowRead)) return const SizedBox.shrink();
    final workflows = ref.watch(workflowChoicesProvider).value;
    if (workflows == null) {
      return const SkeletonBox(width: TixMeasure.field, height: 56);
    }
    Workflow? chosen;
    for (final w in workflows) {
      if (w.key == value || w.id == value || (value.isEmpty && w.builtin)) {
        chosen = w;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: TixSpace.s3),
      child: TixSelectField<String>(
        fieldKey: const Key('project.workflow'),
        label: l10n.projectWorkflow,
        info: l10n.projectWorkflowInfo,
        value: chosen?.key,
        options: [
          for (final w in workflows)
            TixOption(w.key, w.name.isEmpty ? w.key : w.name),
        ],
        onChanged: onChanged == null
            ? null
            : (k) {
                for (final w in workflows) {
                  if (w.key == k) onChanged!(w);
                }
              },
      ),
    );
  }
}

/// Opens the New project form; the created project when saved.
Future<Project?> showCreateProjectSheet(BuildContext context) =>
    showTixSheet<Project>(context, builder: (_) => const _CreateProject());

class _CreateProject extends ConsumerStatefulWidget {
  const _CreateProject();

  @override
  ConsumerState<_CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends ConsumerState<_CreateProject> {
  final _name = TextEditingController();
  final _key = TextEditingController();
  final _description = TextEditingController();
  var _keyEdited = false;
  var _workflow = '';
  var _colour = '';
  var _icon = const ProjectIconValue();
  PickedIcon? _image;
  Object? _error;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _key.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final image = _image;
    final input = CreateProjectInput(
      name: _name.text.trim(),
      key: _key.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      workflowKey: _workflow.isEmpty ? null : _workflow,
      color: _colour.isEmpty ? null : _colour,
      icon: _icon.kind == ProjectIconKind.text && _icon.text.isNotEmpty
          ? _icon.text
          : null,
      iconName: _icon.kind == ProjectIconKind.builtin ? _icon.name : null,
      iconFile: _icon.kind == ProjectIconKind.image && image != null
          ? ProjectIconFile(contentType: image.contentType, data: image.data)
          : null,
    );
    try {
      final created = await ref.read(projectsProvider.notifier).create(input);
      if (!mounted) return;
      showTixToast(context, context.l10n.projectCreated(created.name));
      Navigator.of(context).pop(created);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return TixSheetBody(
      title: l10n.projectNew,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('project.create'),
          label: l10n.projectCreate,
          icon: Icons.add,
          busy: _busy,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            TixNotice(
              errorDetail(l10n, error),
              tone: TixNoticeTone.danger,
              key: const Key('project.error'),
            ),
            const SizedBox(height: TixSpace.s3),
          ],
          TixTextField(
            fieldKey: const Key('project.name'),
            label: l10n.projectName,
            controller: _name,
            autofocus: true,
            onChanged: (v) {
              if (!_keyEdited) _key.text = suggestProjectKey(v);
            },
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('project.key'),
            label: l10n.projectKey,
            controller: _key,
            help: l10n.projectKeyHelp,
            onChanged: (_) => _keyEdited = true,
          ),
          const SizedBox(height: TixSpace.s3),
          WorkflowPicker(
            value: _workflow,
            onChanged: (w) => setState(() => _workflow = w.key),
          ),
          TixTextField(
            fieldKey: const Key('project.description'),
            label: l10n.projectDescription,
            controller: _description,
            maxLines: 6,
          ),
          const SizedBox(height: TixSpace.s4),
          TixFieldLabel(l10n.projectColour),
          TixColourPicker(
            value: _colour,
            onChanged: (c) => setState(() => _colour = c),
          ),
          const SizedBox(height: TixSpace.s3),
          TixFieldLabel(l10n.projectIcon),
          ProjectIconPicker(
            value: _icon,
            names: projectIconNames,
            onChanged: (v) => setState(() => _icon = v),
            imageName: _image?.name,
            onUpload: () async {
              final picked = await pickProjectIcon(ref);
              if (picked != null && mounted) {
                setState(() {
                  _image = picked;
                  _icon = const ProjectIconValue(kind: ProjectIconKind.image);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
