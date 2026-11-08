// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';

/// A database picked in the browser: an existing file, or one to create.
typedef InPlacePick = ({String path, bool create});

/// Lets the person pick a database file under [root], or name a new one in
/// the folder they are in. Null when dismissed.
Future<InPlacePick?> showInPlaceBrowser(
  BuildContext context, {
  required String root,
}) => showTixSheet<InPlacePick>(
  context,
  builder: (_) => InPlaceBrowser(root: root),
);

/// The folders and databases under [root], one folder at a time.
class InPlaceBrowser extends ConsumerStatefulWidget {
  /// Browses from [root], never above it.
  const InPlaceBrowser({required this.root, super.key});

  /// Where browsing starts and stops.
  final String root;

  @override
  ConsumerState<InPlaceBrowser> createState() => _InPlaceBrowserState();
}

class _InPlaceBrowserState extends ConsumerState<InPlaceBrowser> {
  late String _dir = widget.root;
  late Future<List<FolderEntry>> _entries = _list();
  final _name = TextEditingController();

  Future<List<FolderEntry>> _list() =>
      ref.read(localFileAccessProvider).list(_dir);

  void _go(String dir) => setState(() {
    _dir = dir;
    _entries = _list();
  });

  String get _parent {
    final i = _dir.lastIndexOf(RegExp(r'[/\\]'));
    return i <= 0 ? widget.root : _dir.substring(0, i);
  }

  void _create() {
    if (_name.text.trim().isEmpty) return;
    Navigator.of(context).pop<InPlacePick>((
      path: '$_dir/${withDbExtension(_name.text)}',
      create: true,
    ));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final atRoot = _dir == widget.root;
    return TixSheetBody(
      title: l10n.localInstanceBrowseTitle,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('browser.create'),
          label: l10n.localInstanceBrowseCreate,
          icon: Icons.add,
          onPressed: _create,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _dir,
            key: const Key('browser.dir'),
            style: TextStyle(fontSize: TixText.xs, color: context.tix.muted),
          ),
          if (!atRoot)
            ListTile(
              key: const Key('browser.up'),
              leading: const Icon(Icons.arrow_upward),
              title: Text(l10n.localInstanceBrowseUp),
              onTap: () => _go(_parent),
            ),
          FutureBuilder<List<FolderEntry>>(
            future: _entries,
            builder: (context, snap) {
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(TixSpace.s3),
                  child: Text(
                    errorMessage(l10n, snap.error!),
                    key: const Key('browser.error'),
                    style: TextStyle(color: context.tix.danger),
                  ),
                );
              }
              final entries = snap.data;
              if (entries == null) return const SkeletonBox(height: 48);
              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(TixSpace.s3),
                  child: Text(l10n.localInstanceBrowseEmpty),
                );
              }
              return Column(
                children: [
                  for (final e in entries)
                    ListTile(
                      key: Key('browser.entry.${e.name}'),
                      leading: Icon(e.dir ? Icons.folder : Icons.storage),
                      title: Text(e.name),
                      trailing: e.dir ? const Icon(Icons.chevron_right) : null,
                      onTap: () => e.dir
                          ? _go(e.path)
                          : Navigator.of(
                              context,
                            ).pop<InPlacePick>((path: e.path, create: false)),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: TixSpace.s3),
          TextField(
            key: const Key('browser.name'),
            controller: _name,
            autocorrect: false,
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              labelText: l10n.localInstanceBrowseNewLabel,
              suffixText: '.db',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
