// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/pickers.dart'
    show projectIconGlyph;
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/time/times.dart';

// Each kind of fact on a task row has its own shape, so colour alone never
// tells them apart (250-row-markings): the status is the one filled pill, a
// priority is a caret and a word, a tag is a hash and a word, a project is
// its own colour, squared off.

/// A task's status as tix draws it: the one filled mark on a row.
///
/// The colour comes from the [category], never the tenant's accent. Use it
/// wherever a status is shown; wrap it in a button to make it a control.
class StatusPill extends StatelessWidget {
  /// Draws the state [label] in [category].
  const StatusPill({
    required this.label,
    this.category,
    this.framed = false,
    super.key,
  });

  /// The state's name as the workflow spells it.
  final String label;

  /// Its category; guessed from [label] when null.
  final StatusCategory? category;

  /// Draws it as a pressable chip with a chevron, as the task screen does.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final c = category ?? StatusCategory.guess(label);
    final colour = t.status(c);
    final ink = c == StatusCategory.cancelled ? t.muted : colour;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: TixSpace.s2, vertical: 2),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.10),
        border: Border.all(color: colour.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(TixRadius.sm),
      ),
      child: Text(
        label.toLowerCase(),
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontSize: TixText.xs2,
          fontWeight: FontWeight.w600,
          letterSpacing: TixText.xs2 * 0.01,
          height: 1.3,
          color: ink,
        ),
      ),
    );
    if (!framed) return pill;
    return _Framed(child: pill);
  }
}

class _Framed extends StatelessWidget {
  const _Framed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, TixSpace.s2, 3),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(TixRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(width: TixSpace.s1),
          Icon(Icons.arrow_drop_down, size: 16, color: t.muted),
        ],
      ),
    );
  }
}

/// A priority as a caret and a word: up for the two above normal, down for
/// the two below. Normal fades on rows unless [emphasizeNormal].
class PriorityMark extends StatelessWidget {
  /// Draws [priority], 1 the highest and 5 the lowest.
  const PriorityMark({
    required this.priority,
    this.emphasizeNormal = false,
    this.framed = false,
    super.key,
  });

  /// The priority.
  final int priority;

  /// Whether normal priority is drawn at full strength, as on a task screen.
  final bool emphasizeNormal;

  /// Draws it as a pressable chip with a chevron.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final label = context.l10n.priorityLabel('$priority');
    final colour = t.priority(priority);
    final up = priority == 1 || priority == 2;
    final down = priority == 4 || priority == 5;
    final strong = priority == 1 || priority == 5;
    final mark = Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s1,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (up || down) ...[
              Transform.scale(
                scale: strong ? 1.15 : 1,
                child: CustomPaint(
                  size: const Size(8, 6),
                  painter: _Caret(colour: colour, up: up),
                ),
              ),
              const SizedBox(width: 3),
            ],
            Flexible(
              child: Text(
                label.toLowerCase(),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: TixText.xs2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: TixText.xs2 * 0.02,
                  height: 1.3,
                  color: colour,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final shown = priority == 3 && !emphasizeNormal && !framed
        ? Opacity(opacity: 0.3, child: mark)
        : mark;
    return framed ? _Framed(child: shown) : shown;
  }
}

class _Caret extends CustomPainter {
  _Caret({required this.colour, required this.up});

  final Color colour;
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = up
        ? (Path()
            ..moveTo(0, size.height)
            ..lineTo(size.width / 2, 0)
            ..lineTo(size.width, size.height))
        : (Path()
            ..moveTo(0, 0)
            ..lineTo(size.width / 2, size.height)
            ..lineTo(size.width, 0));
    canvas.drawPath(path..close(), Paint()..color = colour);
  }

  @override
  bool shouldRepaint(_Caret old) => old.colour != colour || old.up != up;
}

/// A tag: a faint hash and the word, outlined only when pressable and
/// hovered. Never filled.
class TagChip extends StatelessWidget {
  /// Draws [tag], narrowing a list to it on [onTap].
  const TagChip(this.tag, {this.onTap, super.key});

  /// The tag, without its hash.
  final String tag;

  /// Narrows to the tag, when the screen can.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final chip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: TixSpace.s1, vertical: 1),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '#',
              style: TextStyle(color: t.lineStrong),
            ),
            TextSpan(text: tag),
          ],
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: TixText.xs, color: t.muted, height: 1.4),
      ),
    );
    if (onTap == null) return chip;
    return _Pressable(onTap: onTap!, child: chip);
  }
}

class _Pressable extends StatelessWidget {
  const _Pressable({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(TixRadius.sm),
    hoverColor: context.tix.surface,
    child: child,
  );
}

/// "+3": the tags a row had no room for. Dashed, so it reads as a remainder.
class MoreMark extends StatelessWidget {
  /// Draws [count] more.
  const MoreMark(this.count, {super.key});

  /// How many were left out.
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return CustomPaint(
      painter: DashedBorder(colour: t.lineStrong, radius: TixRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s2,
          vertical: 1,
        ),
        child: Text(
          '+$count',
          style: TextStyle(fontSize: TixText.xs2, color: t.muted, height: 1.4),
        ),
      ),
    );
  }
}

/// A project as tix keys it on a row: its name in its own colour, squared
/// off, with its icon or monogram before it.
class ProjectChip extends StatelessWidget {
  /// Draws the project [projectKey] in [colour] with [icon].
  const ProjectChip({
    required this.projectKey,
    this.colour = '',
    this.icon = '',
    this.onTap,
    super.key,
  });

  /// The project's key or short name.
  final String projectKey;

  /// The stored colour: a palette name or `#rrggbb`; empty for none.
  final String colour;

  /// A text icon: an emoji or a monogram.
  final String icon;

  /// Opens or narrows to the project.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final c = t.projectColour(colour) ?? t.muted;
    final chip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: TixSpace.s1, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon.isNotEmpty) ...[
            Text(icon, style: const TextStyle(fontSize: TixText.sm, height: 1)),
            const SizedBox(width: TixSpace.s1),
          ],
          Flexible(
            child: Text(
              projectKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: TixText.xs2,
                fontWeight: FontWeight.w600,
                color: c,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return _Pressable(onTap: onTap!, child: chip);
  }
}

/// The square a project wears in lists: its icon or monogram on a tint of
/// its colour.
class ProjectMark extends StatelessWidget {
  /// Draws the mark for [name] in [colour], [size] square.
  const ProjectMark({
    required this.name,
    this.colour = '',
    this.icon = '',
    this.iconName = '',
    this.image,
    this.size = 36,
    super.key,
  });

  /// The project's name or key, for the monogram.
  final String name;

  /// The stored colour.
  final String colour;

  /// A text icon, which wins over the monogram.
  final String icon;

  /// One of tix's built-in icons by name, which wins over [icon].
  final String iconName;

  /// The uploaded image, which wins over everything else.
  final Widget? image;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final c = t.projectColour(colour) ?? t.muted;
    final text = icon.isNotEmpty
        ? icon
        : name.characters.take(2).toString().toUpperCase();
    final glyph = projectIconGlyph(iconName);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: image == null ? Clip.none : Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(TixRadius.md),
        ),
        child:
            image ??
            (glyph != null
                ? Icon(glyph, size: size * 0.55, color: c)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: size * 0.42,
                      fontWeight: FontWeight.w700,
                      color: c,
                      height: 1,
                    ),
                  )),
      ),
    );
  }
}

/// "@handle", the assignee on a row; italic and faded for nobody.
class AssigneeRef extends StatelessWidget {
  /// Names [handle]; empty for unassigned.
  const AssigneeRef(this.handle, {super.key});

  /// The handle without its `@`, or empty.
  final String handle;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    if (handle.isEmpty) {
      return Opacity(
        opacity: 0.7,
        child: Text(
          context.l10n.unassigned.toLowerCase(),
          style: TextStyle(
            fontSize: TixText.xs,
            fontStyle: FontStyle.italic,
            color: t.muted,
          ),
        ),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '@',
            style: TextStyle(color: t.lineStrong, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: handle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: TixText.xs,
        fontWeight: FontWeight.w600,
        color: t.muted,
      ),
    );
  }
}

/// A task's reference, `infra-8`, in the monospace face.
class RefText extends StatelessWidget {
  /// Draws [taskRef].
  const RefText(this.taskRef, {this.size, super.key});

  /// The reference.
  final String taskRef;

  /// The font size; [TixText.xs2] by default.
  final double? size;

  @override
  Widget build(BuildContext context) => Text(
    taskRef,
    maxLines: 1,
    softWrap: false,
    style: tixMono(context, size: size ?? TixText.xs2),
  );
}

/// How a due date reads: overdue in danger, today and this week in warn,
/// otherwise the date, quiet.
class DueMark extends StatelessWidget {
  /// Draws [due] relative to [now] (the clock, for tests).
  const DueMark({required this.due, this.now, super.key});

  /// When it is due.
  final DateTime due;

  /// The current time; [DateTime.now] when null.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final style = context.times.style;
    final today = style.day(now ?? DateTime.now());
    final days = style.day(due).difference(today).inDays;
    final (text, colour, dot) = switch (days) {
      < 0 => (l10n.dueOverdue, t.danger, true),
      0 => (l10n.dueToday, t.warn, true),
      < 7 => (l10n.dueOn(style.weekday(due)), t.warn, true),
      _ => (l10n.dueOn(style.dayMonth(due)), t.muted, false),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
          ),
          const SizedBox(width: TixSpace.s1),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: TixText.xs,
              fontWeight: dot ? FontWeight.w600 : FontWeight.w400,
              color: colour,
            ),
          ),
        ),
      ],
    );
  }
}

/// A snoozed task's mark: dashed and muted, it waits on the calendar.
class SnoozeMark extends StatelessWidget {
  /// Draws snoozed until [until].
  const SnoozeMark({required this.until, super.key});

  /// When the snooze ends.
  final DateTime until;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final style = context.times.style;
    return CustomPaint(
      painter: DashedBorder(colour: t.lineStrong, radius: TixRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          context.l10n.snoozedUntil(style.dayMonth(until)),
          style: TextStyle(
            fontSize: TixText.xs2,
            fontWeight: FontWeight.w600,
            color: t.muted,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// The tone of a [TixBadge].
enum TixTone {
  /// Muted, outlined.
  neutral,

  /// The accent on its tint.
  accent,

  /// Success.
  ok,

  /// Needs attention.
  warn,

  /// Failure or destruction.
  danger,
}

/// A small pill of text: a role, a count, a state of something that is not
/// a task. Never use it for a task status; that is [StatusPill].
class TixBadge extends StatelessWidget {
  /// Draws [label] in [tone].
  const TixBadge(this.label, {this.tone = TixTone.neutral, super.key});

  /// The text.
  final String label;

  /// The colour family.
  final TixTone tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final (bg, fg, border) = switch (tone) {
      TixTone.neutral => (t.bg, t.muted, t.line),
      TixTone.accent => (t.accentSoft, t.accent, Colors.transparent),
      TixTone.ok => (t.okSoft, t.ok, Colors.transparent),
      TixTone.warn => (t.warnSoft, t.warn, Colors.transparent),
      TixTone.danger => (t.dangerSoft, t.danger, Colors.transparent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TixSpace.s2, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(TixRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontSize: TixText.xs,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.3,
        ),
      ),
    );
  }
}

/// [value] written for [locale] short enough for a fixed-width tile: in
/// full below 1000, then in the locale's compact form ("1.2K", "1,2 k",
/// "1,2 хил."). Say the full number to screen readers.
String compactCount(int value, String locale) => value.abs() < 1000
    ? NumberFormat.decimalPattern(locale).format(value)
    : NumberFormat.compact(locale: locale).format(value);

/// A count beside a navigation entry or a heading, filled with the accent.
class TixCounter extends StatelessWidget {
  /// Draws [count]; 100 and over read "99+".
  const TixCounter(this.count, {super.key});

  /// The number.
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: t.accent,
        borderRadius: BorderRadius.circular(TixRadius.pill),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: TixText.xs2,
          fontWeight: FontWeight.w700,
          color: t.onAccent,
          fontFeatures: const [FontFeature.tabularFigures()],
          height: 1.4,
        ),
      ),
    );
  }
}

/// A key or chord as tix draws it in its shortcut help.
class Kbd extends StatelessWidget {
  /// Draws [keys], such as `Ctrl K` or `?`.
  const Kbd(this.keys, {super.key});

  /// The key label.
  final String keys;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: t.bg,
        border: Border(
          top: BorderSide(color: t.lineStrong),
          left: BorderSide(color: t.lineStrong),
          right: BorderSide(color: t.lineStrong),
          bottom: BorderSide(color: t.lineStrong, width: 2),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(keys, style: tixMono(context, color: t.ink)),
    );
  }
}

/// A dashed rounded outline, for marks that stand for something absent or
/// pending: a remainder, a snooze, a placeholder.
class DashedBorder extends CustomPainter {
  /// Dashes in [colour] round a rectangle with corners of [radius].
  DashedBorder({required this.colour, this.radius = TixRadius.sm});

  /// The dash colour.
  final Color colour;

  /// The corner radius.
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius.clamp(0, size.shortestSide / 2).toDouble();
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(r),
        ).deflate(0.5),
      );
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 3), paint);
        d += 6;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorder old) =>
      old.colour != colour || old.radius != radius;
}
