// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/gallery/presentation/gallery_sections.dart';

/// Every component, in light, dark or OLED black and any tenant accent: the
/// reference for anyone building a screen. Only routed in debug and profile
/// builds, or with `--dart-define=TIX_GALLERY=true`.
class GalleryScreen extends ConsumerStatefulWidget {
  /// Creates the gallery.
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  TixTokens? _scheme;
  TixAccent _accent = TixAccent.standard;

  static final List<TixAccent> _accents = [
    ...TixAccent.builtIn,
    TixAccent.resolve('#7a3ef0'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme =
        _scheme ??
        (context.tix.isBlack
            ? TixTokens.oled
            : TixTokens.of(Theme.of(context).brightness));
    final registry = ref.watch(commandRegistryProvider);
    return Theme(
      data: buildTixTheme(scheme.brightness, accent: _accent, base: scheme),
      child: Builder(
        builder: (context) => TixPage(
          title: l10n.galleryTitle,
          actions: [
            TixIconButton(
              key: const Key('gallery.brightness'),
              icon: scheme.isBlack
                  ? Icons.light_mode
                  : scheme.isDark
                  ? Icons.contrast
                  : Icons.dark_mode,
              tooltip: l10n.themeLabel,
              onPressed: () => setState(
                () => _scheme = scheme.isBlack
                    ? TixTokens.light
                    : scheme.isDark
                    ? TixTokens.oled
                    : TixTokens.dark,
              ),
            ),
            PopupMenuButton<TixAccent>(
              key: const Key('gallery.accent'),
              tooltip: 'Accent',
              icon: Icon(Icons.palette_outlined, color: context.tix.accent),
              onSelected: (a) => setState(() => _accent = a),
              itemBuilder: (_) => [
                for (final a in _accents)
                  PopupMenuItem(
                    value: a,
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: a.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: TixSpace.s2),
                        Text(a.name),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          body: Material(
            color: context.tix.bg,
            child: ListView(
              padding: const EdgeInsets.only(bottom: TixSpace.s7),
              children: [
                const GalleryBlock(title: 'Tokens', child: GalleryTokens()),
                const GalleryBlock(title: 'Buttons', child: GalleryButtons()),
                const GalleryBlock(title: 'Markings', child: GalleryMarks()),
                const GalleryBlock(title: 'Live', child: GalleryLive()),
                const GalleryBlock(title: 'Tasks', child: GalleryTasks()),
                const GalleryBlock(title: 'Inbox', child: GalleryInbox()),
                const GalleryBlock(title: 'Sync', child: GallerySync()),
                const GalleryBlock(title: 'Forms', child: GalleryForms()),
                const GalleryBlock(title: 'Choices', child: GalleryChoices()),
                const GalleryBlock(title: 'States', child: GalleryStates()),
                const GalleryBlock(title: 'Record', child: GalleryRecord()),
                const GalleryBlock(title: 'Manage', child: GalleryManage()),
                const GalleryBlock(title: 'Panes', child: GalleryPanes()),
                GalleryBlock(
                  title: 'Overlays',
                  child: GalleryOverlays(registry: registry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
