// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/section.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// One option of a [TixSelectField].
@immutable
class TixOption<T> {
  /// The option [value], shown as [label].
  const TixOption(this.value, this.label);

  /// What choosing it answers.
  final T value;

  /// What it reads as.
  final String label;
}

/// A labelled choice of one value from a short list, drawn like a
/// [TixTextField]: label above, help and error below.
///
/// For a long or searchable list open a chooser with `showTixSheet`
/// instead.
class TixSelectField<T> extends StatelessWidget {
  /// A choice labelled [label] among [options].
  const TixSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.help,
    this.error,
    this.info,
    this.fieldKey,
    this.width = TixMeasure.field,
    super.key,
  });

  /// What is chosen.
  final String label;

  /// The chosen value; null shows no choice.
  final T? value;

  /// The choices, in order.
  final List<TixOption<T>> options;

  /// Called with the new value; null disables the field.
  final ValueChanged<T?>? onChanged;

  /// Help under the field.
  final String? help;

  /// An error under the field, in the danger colour.
  final String? error;

  /// An (i) explanation beside the label.
  final String? info;

  /// The key of the dropdown itself, for tests.
  final Key? fieldKey;

  /// The widest it grows.
  final double width;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final known = options.any((o) => o.value == value);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: TixText.xs,
                      fontWeight: FontWeight.w500,
                      color: t.muted,
                    ),
                  ),
                ),
                if (info != null) InfoTip(info!, size: 32),
              ],
            ),
            const SizedBox(height: TixSpace.s1),
            DropdownButtonFormField<T>(
              key: fieldKey,
              initialValue: known ? value : null,
              isExpanded: true,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontSize: TixText.md, color: t.ink),
              decoration: InputDecoration(
                semanticCounterText: label,
                helperText: help,
                errorText: error,
              ),
              items: [
                for (final o in options)
                  DropdownMenuItem<T>(
                    value: o.value,
                    child: Text(o.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The name a person reads for the project colour [c].
String projectColourName(AppLocalizations l10n, ProjectColour c) => switch (c) {
  ProjectColour.slate => l10n.colourSlate,
  ProjectColour.red => l10n.colourRed,
  ProjectColour.amber => l10n.colourAmber,
  ProjectColour.green => l10n.colourGreen,
  ProjectColour.teal => l10n.colourTeal,
  ProjectColour.blue => l10n.colourBlue,
  ProjectColour.violet => l10n.colourViolet,
  ProjectColour.pink => l10n.colourPink,
};

final _hex = RegExp(r'^#[0-9a-fA-F]{6}$');

/// A project's colour: none, one of the eight palette swatches, or a
/// custom `#rrggbb`, as tix's colour field offers them.
///
/// [value] is what a project stores: empty, a palette name or a hex value.
/// The swatches are drawn in the scheme's own shade, as rows show them.
class TixColourPicker extends StatefulWidget {
  /// A picker showing [value].
  const TixColourPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The stored colour.
  final String value;

  /// Called with the new stored value; null disables the picker.
  final ValueChanged<String>? onChanged;

  @override
  State<TixColourPicker> createState() => _TixColourPickerState();
}

class _TixColourPickerState extends State<TixColourPicker> {
  late final _custom = TextEditingController(
    text: widget.value.startsWith('#') ? widget.value : '',
  );

  @override
  void didUpdateWidget(TixColourPicker old) {
    super.didUpdateWidget(old);
    if (!widget.value.startsWith('#') && _custom.text.isNotEmpty) {
      _custom.clear();
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final enabled = widget.onChanged != null;
    final current = widget.value.toLowerCase();
    Widget swatch({
      required String value,
      required String label,
      Color? colour,
    }) {
      final selected = current == value;
      return Semantics(
        label: label,
        selected: selected,
        button: true,
        excludeSemantics: true,
        child: Tooltip(
          message: label,
          child: InkResponse(
            key: Key('colour.${value.isEmpty ? 'none' : value}'),
            onTap: enabled ? () => widget.onChanged!(value) : null,
            radius: TixSize.target / 2,
            child: SizedBox.square(
              dimension: TixSize.target,
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colour ?? t.bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? t.ink : t.lineStrong,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: colour == null
                      ? Icon(Icons.block, size: 16, color: t.muted)
                      : selected
                      ? Icon(Icons.check, size: 16, color: t.bg)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          children: [
            swatch(value: '', label: l10n.colourNone),
            for (final c in ProjectColour.values)
              swatch(
                value: c.name,
                label: projectColourName(l10n, c),
                colour: t.projects[c],
              ),
          ],
        ),
        const SizedBox(height: TixSpace.s2),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: TextField(
            key: const Key('colour.custom'),
            controller: _custom,
            enabled: enabled,
            maxLength: 7,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
            ],
            onChanged: (v) {
              if (_hex.hasMatch(v)) widget.onChanged?.call(v.toLowerCase());
            },
            style: const TextStyle(fontSize: TixText.md),
            decoration: InputDecoration(
              labelText: l10n.colourCustom,
              hintText: '#rrggbb',
              counterText: '',
              prefixIcon: current.startsWith('#')
                  ? Icon(Icons.circle, color: t.projectColour(current))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// The glyph for tix's built-in project icon [name], or null when the name
/// is not one this app knows.
IconData? projectIconGlyph(String name) => switch (name) {
  'folder' => Icons.folder_outlined,
  'briefcase' => Icons.work_outline,
  'home' => Icons.home_outlined,
  'server' => Icons.dns_outlined,
  'database' => Icons.storage,
  'cloud' => Icons.cloud_outlined,
  'code' => Icons.code,
  'terminal' => Icons.terminal,
  'bug' => Icons.bug_report_outlined,
  'rocket' => Icons.rocket_launch_outlined,
  'shield' => Icons.shield_outlined,
  'lock' => Icons.lock_outline,
  'globe' => Icons.public,
  'chart' => Icons.bar_chart,
  'book' => Icons.menu_book_outlined,
  'users' => Icons.group_outlined,
  'package' => Icons.inventory_2_outlined,
  'wrench' => Icons.build_outlined,
  'flask' => Icons.science_outlined,
  'bolt' => Icons.bolt,
  _ => null,
};

/// Which kind of icon a project wears.
enum ProjectIconKind {
  /// No icon: the monogram from the name.
  none,

  /// One emoji or a one or two letter monogram.
  text,

  /// One of tix's built-in icons.
  builtin,

  /// An uploaded image.
  image,
}

/// A project's icon as [ProjectIconPicker] edits it.
@immutable
class ProjectIconValue {
  /// An icon of [kind].
  const ProjectIconValue({
    this.kind = ProjectIconKind.none,
    this.text = '',
    this.name = '',
  });

  /// Which kind it is.
  final ProjectIconKind kind;

  /// The emoji or monogram, for [ProjectIconKind.text].
  final String text;

  /// The built-in icon's name, for [ProjectIconKind.builtin].
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ProjectIconValue &&
      other.kind == kind &&
      other.text == text &&
      other.name == name;

  @override
  int get hashCode => Object.hash(kind, text, name);
}

/// A project's icon: none, an emoji or monogram, one of tix's built-in
/// icons, or an uploaded image, chosen with a segmented control as tix's
/// icon field offers them.
class ProjectIconPicker extends StatefulWidget {
  /// A picker showing [value] from the built-in [names].
  const ProjectIconPicker({
    required this.value,
    required this.names,
    required this.onChanged,
    this.image,
    this.onUpload,
    this.imageName,
    super.key,
  });

  /// The icon chosen.
  final ProjectIconValue value;

  /// The built-in icon names tix offers, in order.
  final List<String> names;

  /// Called with the new icon; null disables the picker.
  final ValueChanged<ProjectIconValue>? onChanged;

  /// The current or picked image, drawn when the kind is image.
  final Widget? image;

  /// Picks an image; null hides the image option.
  final VoidCallback? onUpload;

  /// The picked file's name, shown beside the image.
  final String? imageName;

  @override
  State<ProjectIconPicker> createState() => _ProjectIconPickerState();
}

class _ProjectIconPickerState extends State<ProjectIconPicker> {
  late final _text = TextEditingController(text: widget.value.text);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _set(ProjectIconValue v) => widget.onChanged?.call(v);

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final v = widget.value;
    final enabled = widget.onChanged != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<ProjectIconKind>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ProjectIconKind.none,
                label: Text(l10n.iconNone),
              ),
              ButtonSegment(
                value: ProjectIconKind.text,
                label: Text(l10n.iconText),
              ),
              ButtonSegment(
                value: ProjectIconKind.builtin,
                label: Text(l10n.iconBuiltin),
              ),
              if (widget.onUpload != null || v.kind == ProjectIconKind.image)
                ButtonSegment(
                  value: ProjectIconKind.image,
                  label: Text(l10n.iconImage),
                ),
            ],
            selected: {v.kind},
            onSelectionChanged: enabled
                ? (s) => _set(
                    ProjectIconValue(
                      kind: s.single,
                      text: _text.text,
                      name:
                          v.name.isEmpty && s.single == ProjectIconKind.builtin
                          ? widget.names.first
                          : v.name,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: TixSpace.s3),
        switch (v.kind) {
          ProjectIconKind.none => Text(
            l10n.iconNoneHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ProjectIconKind.text => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: TextField(
              key: const Key('icon.text'),
              controller: _text,
              enabled: enabled,
              onChanged: (s) => _set(
                ProjectIconValue(
                  kind: ProjectIconKind.text,
                  text: s.characters.take(2).toString(),
                  name: v.name,
                ),
              ),
              style: const TextStyle(fontSize: TixText.md),
              decoration: InputDecoration(
                labelText: l10n.iconTextLabel,
                helperText: l10n.iconTextHelp,
              ),
            ),
          ),
          ProjectIconKind.builtin => Wrap(
            children: [
              for (final name in widget.names)
                _GlyphChoice(
                  name: name,
                  selected: v.name == name,
                  onTap: enabled
                      ? () => _set(
                          ProjectIconValue(
                            kind: ProjectIconKind.builtin,
                            text: v.text,
                            name: name,
                          ),
                        )
                      : null,
                ),
            ],
          ),
          ProjectIconKind.image => Row(
            children: [
              Container(
                width: TixSize.target,
                height: TixSize.target,
                decoration: BoxDecoration(
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(TixRadius.md),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    widget.image ?? Icon(Icons.image_outlined, color: t.muted),
              ),
              const SizedBox(width: TixSpace.s3),
              Flexible(
                child: Text(
                  widget.imageName ?? l10n.iconImageHelp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (widget.onUpload != null) ...[
                const SizedBox(width: TixSpace.s3),
                TixButton(
                  key: const Key('icon.upload'),
                  label: l10n.iconUpload,
                  icon: Icons.upload_outlined,
                  size: TixButtonSize.small,
                  onPressed: enabled ? widget.onUpload : null,
                ),
              ],
            ],
          ),
        },
      ],
    );
  }
}

class _GlyphChoice extends StatelessWidget {
  const _GlyphChoice({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Tooltip(
      message: name,
      child: Semantics(
        label: name,
        selected: selected,
        button: true,
        excludeSemantics: true,
        child: InkWell(
          key: Key('icon.$name'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(TixRadius.md),
          child: Container(
            width: TixSize.target,
            height: TixSize.target,
            decoration: BoxDecoration(
              color: selected ? t.accentSoft : null,
              border: Border.all(
                color: selected ? t.accent : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(TixRadius.md),
            ),
            child: Icon(
              projectIconGlyph(name) ?? Icons.help_outline,
              size: 22,
              color: selected ? t.accent : t.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// The label above a control that has none of its own, such as a picker,
/// drawn as a text field draws its label.
class TixFieldLabel extends StatelessWidget {
  /// A label reading [text].
  const TixFieldLabel(this.text, {super.key});

  /// What it says.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: TixSpace.s1),
    child: Text(
      text,
      style: TextStyle(
        fontSize: TixText.xs,
        fontWeight: FontWeight.w500,
        color: context.tix.muted,
      ),
    ),
  );
}
