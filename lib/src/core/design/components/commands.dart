// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

part 'commands.g.dart';

/// Something the app can do from the keyboard or the command palette.
@immutable
class TixCommand {
  /// A command [id] labelled [label] that calls [run].
  const TixCommand({
    required this.id,
    required this.label,
    required this.run,
    this.group = '',
    this.icon,
    this.shortcut,
  });

  /// Unique among the registered commands; a later registration with the
  /// same id replaces an earlier one while it is mounted.
  final String id;

  /// What it does, as a verb phrase: "New task".
  final String label;

  /// The heading it is listed under in the help and the palette.
  final String group;

  /// An icon in the palette.
  final IconData? icon;

  /// The key that runs it, or null for palette only.
  final ShortcutActivator? shortcut;

  /// Does it.
  final VoidCallback run;
}

/// How [a] reads in the shortcut help: `Ctrl K`, `?`, `N`.
String shortcutLabel(ShortcutActivator a) {
  if (a is CharacterActivator) {
    return [
      if (a.control) 'Ctrl',
      if (a.meta) '⌘',
      if (a.alt) 'Alt',
      a.character.toUpperCase(),
    ].join(' ');
  }
  if (a is SingleActivator) {
    return [
      if (a.control) 'Ctrl',
      if (a.meta) '⌘',
      if (a.alt) 'Alt',
      if (a.shift) 'Shift',
      a.trigger.keyLabel.toUpperCase(),
    ].join(' ');
  }
  return '';
}

/// Every command mounted screens have registered, newest last.
class CommandRegistry {
  final _scopes = <Object, List<TixCommand>>{};
  final _changes = ValueNotifier<int>(0);
  bool _disposed = false;

  /// Ticks whenever the commands change.
  Listenable get changes => _changes;

  /// Stops notifying; later calls do nothing.
  void dispose() {
    _disposed = true;
    _changes.dispose();
  }

  void _notify() => _changes.value++;

  /// The commands, one per id, the most recently registered winning.
  List<TixCommand> get commands {
    final byId = <String, TixCommand>{};
    for (final list in _scopes.values) {
      for (final c in list) {
        byId.remove(c.id);
        byId[c.id] = c;
      }
    }
    return byId.values.toList();
  }

  /// Registers [commands] under [owner], replacing what it had.
  void register(Object owner, List<TixCommand> commands) {
    if (_disposed) return;
    _scopes
      ..remove(owner)
      ..[owner] = commands;
    _notify();
  }

  /// Removes what [owner] registered.
  void unregister(Object owner) {
    if (!_disposed && _scopes.remove(owner) != null) _notify();
  }
}

/// The app's command registry. Features add to it with [CommandScope].
@Riverpod(keepAlive: true)
CommandRegistry commandRegistry(Ref ref) {
  final registry = CommandRegistry();
  ref.onDispose(registry.dispose);
  return registry;
}

/// Registers [commands] while this widget is mounted: a screen's own
/// actions join the palette and the shortcuts when the screen shows and
/// leave when it goes.
class CommandScope extends ConsumerStatefulWidget {
  /// Registers [commands] around [child].
  const CommandScope({required this.commands, required this.child, super.key});

  /// The commands.
  final List<TixCommand> commands;

  /// The screen.
  final Widget child;

  @override
  ConsumerState<CommandScope> createState() => _CommandScopeState();
}

class _CommandScopeState extends ConsumerState<CommandScope> {
  late final CommandRegistry _registry = ref.read(commandRegistryProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _registry.register(this, widget.commands);
    });
  }

  @override
  void didUpdateWidget(CommandScope old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.commands, widget.commands)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _registry.register(this, widget.commands);
      });
    }
  }

  @override
  void dispose() {
    final registry = _registry;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => registry.unregister(this),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Listens for every registered shortcut below the navigator, plus `?` for
/// the shortcut help and Ctrl+K or ⌘K for the command palette. Keys typed
/// into a text field stay in the field.
class TixShortcuts extends ConsumerWidget {
  /// Handles shortcuts for [child].
  const TixShortcuts({required this.child, super.key});

  /// The screens.
  final Widget child;

  static bool _typing() {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return false;
    if (focused.widget is EditableText) return true;
    return focused.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(commandRegistryProvider);
    return ListenableBuilder(
      listenable: registry.changes,
      builder: (context, child) {
        VoidCallback guarded(VoidCallback run, {bool always = false}) => () {
          if (always || !_typing()) run();
        };
        final bindings = <ShortcutActivator, VoidCallback>{
          const CharacterActivator('?'): guarded(
            () => showShortcutHelp(context, registry.commands),
          ),
          const SingleActivator(
            LogicalKeyboardKey.keyK,
            control: true,
          ): guarded(
            () => showCommandPalette(context, registry),
            always: true,
          ),
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): guarded(
            () => showCommandPalette(context, registry),
            always: true,
          ),
          for (final c in registry.commands)
            if (c.shortcut != null) c.shortcut!: guarded(c.run),
        };
        return CallbackShortcuts(
          bindings: bindings,
          child: Focus(autofocus: true, child: child!),
        );
      },
      child: child,
    );
  }
}

/// tix's `?` overlay: every command that has a key, with the key.
Future<void> showShortcutHelp(BuildContext context, List<TixCommand> commands) {
  final l10n = context.l10n;
  final keyed = [
    (label: l10n.openCommandPalette, keys: 'Ctrl K'),
    (label: l10n.showShortcuts, keys: '?'),
    for (final c in commands)
      if (c.shortcut != null)
        (label: c.label, keys: shortcutLabel(c.shortcut!)),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      key: const Key('shortcuts.help'),
      title: Text(l10n.shortcutsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final k in keyed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Kbd(k.keys),
                        ),
                      ),
                      const SizedBox(width: TixSpace.s4),
                      Expanded(
                        child: Text(
                          k.label,
                          style: TextStyle(color: context.tix.muted),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}

/// The command palette: type to narrow, Enter or a tap to run.
Future<void> showCommandPalette(
  BuildContext context,
  CommandRegistry registry,
) async {
  final picked = await showDialog<TixCommand>(
    context: context,
    builder: (context) => _Palette(commands: registry.commands),
  );
  picked?.run();
}

class _Palette extends StatefulWidget {
  const _Palette({required this.commands});

  final List<TixCommand> commands;

  @override
  State<_Palette> createState() => _PaletteState();
}

class _PaletteState extends State<_Palette> {
  String _query = '';
  int _index = 0;

  List<TixCommand> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.commands;
    return [
      for (final c in widget.commands)
        if ('${c.group} ${c.label}'.toLowerCase().contains(q)) c,
    ];
  }

  void _move(int by) {
    final n = _matches.length;
    if (n == 0) return;
    setState(() => _index = (_index + by) % n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final matches = _matches;
    final index = matches.isEmpty ? 0 : _index.clamp(0, matches.length - 1);
    return Dialog(
      key: const Key('palette'),
      alignment: const Alignment(0, -0.6),
      insetPadding: const EdgeInsets.all(TixSpace.s4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 440),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: TextField(
                  key: const Key('palette.query'),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.commandSearchHint,
                    prefixIcon: const Icon(Icons.search, size: 18),
                  ),
                  onChanged: (v) => setState(() {
                    _query = v;
                    _index = 0;
                  }),
                  onSubmitted: (_) {
                    if (matches.isNotEmpty) {
                      Navigator.of(context).pop(matches[index]);
                    }
                  },
                ),
              ),
              const Divider(),
              Flexible(
                child: matches.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(TixSpace.s5),
                        child: Text(
                          l10n.commandNone,
                          style: TextStyle(color: t.muted),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(TixSpace.s1),
                        itemCount: matches.length,
                        itemBuilder: (context, i) {
                          final c = matches[i];
                          return ListTile(
                            key: Key('palette.${c.id}'),
                            dense: true,
                            selected: i == index,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(TixRadius.sm),
                              ),
                            ),
                            leading: c.icon == null
                                ? null
                                : Icon(c.icon, size: 18),
                            title: Text(c.label),
                            subtitle: c.group.isEmpty ? null : Text(c.group),
                            trailing: c.shortcut == null
                                ? null
                                : Kbd(shortcutLabel(c.shortcut!)),
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
