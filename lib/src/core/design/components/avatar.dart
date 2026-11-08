// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// The one or two letters an avatar shows, tix's `monogramOf`: the first
/// letter of the first two words that start with one, upper case.
String monogramOf(String label) {
  final trimmed = label.trim().replaceFirst(RegExp('^@'), '');
  if (trimmed.isEmpty) return '?';
  final letter = RegExp(r'\p{L}', unicode: true);
  final initials = <String>[];
  for (final word in trimmed.split(RegExp(r'\s+'))) {
    final m = letter.firstMatch(word);
    if (m != null) initials.add(m[0]!);
    if (initials.length == 2) break;
  }
  if (initials.isEmpty) return trimmed.characters.first.toUpperCase();
  return initials.join().toUpperCase();
}

/// A stable palette colour for [seed], the same on every device.
ProjectColour hueOf(String seed) {
  var h = 0x811c9dc5;
  for (final unit in seed.toLowerCase().codeUnits) {
    h = ((h ^ unit) * 0x01000193) & 0xffffffff;
  }
  return ProjectColour.values[h % ProjectColour.values.length];
}

/// A person or agent as a circle of initials.
///
/// tix draws avatars in the accent on its tint. [hued] picks a palette
/// colour from [seed] (the handle) instead, for lists where telling people
/// apart at a glance matters, such as assignees on a board.
class TixAvatar extends StatelessWidget {
  /// An avatar for [label], [size] across.
  const TixAvatar({
    required this.label,
    this.seed = '',
    this.hued = false,
    this.size = 34,
    this.icon,
    super.key,
  });

  /// The name the initials come from.
  final String label;

  /// What the hue is derived from; [label] when empty.
  final String seed;

  /// Whether the colour comes from [seed] rather than the accent.
  final bool hued;

  /// The diameter.
  final double size;

  /// An icon drawn in place of initials, such as an instance's kind.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final (bg, fg) = hued
        ? (
            t.projects[hueOf(seed.isEmpty ? label : seed)]!.withValues(
              alpha: 0.16,
            ),
            t.projects[hueOf(seed.isEmpty ? label : seed)]!,
          )
        : (t.accentSoft, t.accent);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: icon != null
            ? Icon(icon, size: size * 0.55, color: fg)
            : Text(
                monogramOf(label),
                maxLines: 1,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: size * 0.38 * 0.02,
                  color: fg,
                  height: 1,
                ),
              ),
      ),
    );
  }
}
