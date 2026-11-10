// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show CharacterActivator, ShortcutActivator, SingleActivator;

/// The abstract actions a keymap binds, in the order the help lists them.
abstract final class KeyActions {
  /// Opens the command palette.
  static const paletteOpen = 'palette.open';

  /// Shows the shortcut help.
  static const helpShow = 'help.show';

  /// Moves focus out of the text field being typed in.
  static const fieldLeave = 'field.leave';

  /// Goes back a page.
  static const navBack = 'nav.back';

  /// Opens Projects.
  static const navProjects = 'nav.projects';

  /// Opens Tasks.
  static const navTasks = 'nav.tasks';

  /// Opens My work.
  static const navMyWork = 'nav.myWork';

  /// Opens the inbox.
  static const navInbox = 'nav.inbox';

  /// Opens Manage.
  static const navManage = 'nav.manage';

  /// Opens Settings.
  static const navSettings = 'nav.settings';

  /// Opens Watch.
  static const navWatch = 'nav.watch';

  /// Opens quick add.
  static const quickAdd = 'quick.add';

  /// Quick adds what is on the clipboard.
  static const quickPaste = 'quick.paste';

  /// Moves to the next row.
  static const listNext = 'list.next';

  /// Moves to the previous row.
  static const listPrev = 'list.prev';

  /// Moves to the first row.
  static const listTop = 'list.top';

  /// Moves to the last row.
  static const listBottom = 'list.bottom';

  /// Moves a page down.
  static const listPageDown = 'list.pageDown';

  /// Moves a page up.
  static const listPageUp = 'list.pageUp';

  /// Opens the row.
  static const listOpen = 'list.open';

  /// Selects or unselects the row.
  static const listSelect = 'list.select';

  /// Extends the selection down.
  static const listExtendDown = 'list.extendDown';

  /// Extends the selection up.
  static const listExtendUp = 'list.extendUp';

  /// Selects every row.
  static const listSelectAll = 'list.selectAll';

  /// Clears the selection.
  static const listClear = 'list.clear';

  /// Focuses the filter.
  static const listFilter = 'list.filter';

  /// Reloads the list.
  static const listRefresh = 'list.refresh';

  /// Switches the view.
  static const listView = 'list.view';

  /// Adds an item.
  static const listNew = 'list.new';

  /// Marks the row done.
  static const listDone = 'list.done';

  /// Renames the task.
  static const taskRename = 'task.rename';

  /// Edits the task's description.
  static const taskDescribe = 'task.describe';

  /// Moves the task to another status.
  static const taskMove = 'task.move';

  /// Sets the priority.
  static const taskPriority = 'task.priority';

  /// Sets the assignee.
  static const taskAssign = 'task.assign';

  /// Sets the due date.
  static const taskDue = 'task.due';

  /// Adds a tag.
  static const taskTag = 'task.tag';

  /// Stars or unstars.
  static const taskStar = 'task.star';

  /// Snoozes or wakes.
  static const taskSnooze = 'task.snooze';

  /// Comments.
  static const taskComment = 'task.comment';

  /// Copies the task.
  static const taskCopy = 'task.copy';

  /// Deletes the task, after a confirmation.
  static const taskDelete = 'task.delete';
}

/// The shipped keymaps, as tix's web and terminal interfaces name them.
enum KeymapPreset {
  /// The app's own keys plus tix web's.
  standard,

  /// Vim reflexes over the default.
  vim,

  /// Emacs reflexes over the default.
  emacs,

  /// Chords only: no single key runs anything.
  off;

  /// The name it is stored by.
  String get id => this == standard ? 'default' : name;

  /// The preset stored as [id], Default for anything unknown.
  static KeymapPreset byId(String? id) =>
      values.firstWhere((p) => p.id == id, orElse: () => standard);
}

/// One key, or one chord of modifiers and a key. A stroke with a
/// [character] matches by what the key types, ignoring Shift, as
/// [CharacterActivator] does; otherwise it matches the logical key and every
/// modifier.
@immutable
class KeyStroke {
  /// The logical [key] with these modifiers.
  const KeyStroke(
    LogicalKeyboardKey this.key, {
    this.control = false,
    this.meta = false,
    this.alt = false,
    this.shift = false,
  }) : character = null;

  /// Whatever key types [character], with these modifiers.
  const KeyStroke.char(
    String this.character, {
    this.control = false,
    this.meta = false,
    this.alt = false,
  }) : key = null,
       shift = false;

  /// The key, or null for a [character] stroke.
  final LogicalKeyboardKey? key;

  /// What the key types, or null for a [key] stroke.
  final String? character;

  /// Ctrl held.
  final bool control;

  /// Cmd, Win or Super held.
  final bool meta;

  /// Alt or Option held.
  final bool alt;

  /// Shift held.
  final bool shift;

  /// Whether Ctrl, Alt or Cmd is held: a chord, which Off keeps.
  bool get chorded => control || meta || alt;

  /// Whether [press] is this stroke.
  bool matches(KeyPress press) {
    if (press.control != control || press.meta != meta || press.alt != alt) {
      return false;
    }
    final c = character;
    if (c != null) return press.character == c;
    return press.key == key && press.shift == shift;
  }

  /// The parts of its label: `Ctrl`, `K`; `g`; `G`; `↓`. A plain letter is
  /// lower case and Shift makes it upper case, as Vim writes them; a chord
  /// writes its letter upper case.
  List<String> get parts {
    final letter = _isLetter;
    final shifted = shift ? _shifted[key] : null;
    return [
      if (control) 'Ctrl',
      if (meta) '⌘',
      if (alt) 'Alt',
      if (shift && shifted == null && (!letter || chorded)) 'Shift',
      character ??
          shifted ??
          _keyName(key!, upper: letter && (shift || chorded)),
    ];
  }

  bool get _isLetter =>
      key != null &&
      key!.keyId >= LogicalKeyboardKey.keyA.keyId &&
      key!.keyId <= LogicalKeyboardKey.keyZ.keyId;

  /// How it reads in the help: `Ctrl K`, `g`, `G`, `Shift ↓`.
  String get label => parts.join(' ');

  @override
  bool operator ==(Object other) =>
      other is KeyStroke &&
      other.key == key &&
      other.character == character &&
      other.control == control &&
      other.meta == meta &&
      other.alt == alt &&
      other.shift == shift;

  @override
  int get hashCode => Object.hash(key, character, control, meta, alt, shift);

  @override
  String toString() => label;
}

String _keyName(LogicalKeyboardKey key, {required bool upper}) {
  final named = _names[key];
  if (named != null) return named;
  final label = key.keyLabel;
  if (label.length != 1) return label;
  return upper ? label.toUpperCase() : label.toLowerCase();
}

final Map<LogicalKeyboardKey, String> _shifted = {
  LogicalKeyboardKey.comma: '<',
  LogicalKeyboardKey.period: '>',
};

final Map<LogicalKeyboardKey, String> _names = {
  LogicalKeyboardKey.arrowDown: '↓',
  LogicalKeyboardKey.arrowUp: '↑',
  LogicalKeyboardKey.arrowLeft: '←',
  LogicalKeyboardKey.arrowRight: '→',
  LogicalKeyboardKey.escape: 'Esc',
  LogicalKeyboardKey.enter: 'Enter',
  LogicalKeyboardKey.space: 'Space',
  LogicalKeyboardKey.delete: 'Delete',
  LogicalKeyboardKey.home: 'Home',
  LogicalKeyboardKey.end: 'End',
  LogicalKeyboardKey.pageDown: 'PgDn',
  LogicalKeyboardKey.pageUp: 'PgUp',
  LogicalKeyboardKey.comma: ',',
  LogicalKeyboardKey.period: '.',
};

/// A key that went down, with the modifiers held, in the form a keymap
/// matches.
@immutable
class KeyPress {
  /// The [key] typing [character], with these modifiers.
  const KeyPress(
    this.key, {
    this.character,
    this.control = false,
    this.meta = false,
    this.alt = false,
    this.shift = false,
  });

  /// [event] with the modifiers [keyboard] says are held.
  factory KeyPress.from(KeyEvent event, HardwareKeyboard keyboard) => KeyPress(
    event.logicalKey,
    character: event.character,
    control: keyboard.isControlPressed,
    meta: keyboard.isMetaPressed,
    alt: keyboard.isAltPressed,
    shift: keyboard.isShiftPressed,
  );

  /// The logical key.
  final LogicalKeyboardKey key;

  /// What it typed, if anything.
  final String? character;

  /// Ctrl held.
  final bool control;

  /// Cmd held.
  final bool meta;

  /// Alt held.
  final bool alt;

  /// Shift held.
  final bool shift;

  /// Whether the key is a modifier on its own, which never starts or breaks
  /// a sequence.
  bool get isModifier => _modifiers.contains(key);

  @override
  String toString() =>
      '${key.keyLabel}${character == null ? '' : '/'}'
      '${character ?? ''}';
}

final Set<LogicalKeyboardKey> _modifiers = {
  LogicalKeyboardKey.shift,
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight,
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight,
  LogicalKeyboardKey.alt,
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight,
  LogicalKeyboardKey.meta,
  LogicalKeyboardKey.metaLeft,
  LogicalKeyboardKey.metaRight,
  LogicalKeyboardKey.capsLock,
  LogicalKeyboardKey.fn,
};

/// Where a binding applies relative to text fields.
enum FieldRule {
  /// Only while no text field has focus: most bindings.
  outside,

  /// Whether or not a text field has focus: the palette chord.
  also,

  /// Only while a text field has focus: leaving the field.
  only,
}

/// The keys that run an action: one stroke, or a sequence of them.
@immutable
class KeyBinding {
  /// [steps] pressed in order, applying as [fields] says.
  const KeyBinding(this.steps, {this.fields = FieldRule.outside});

  /// Parses [spec]: steps split by spaces, each `ctrl+alt+meta+shift+key`,
  /// where the key is a letter (upper case means Shift), a digit, a name
  /// such as `down`, `esc` or `pgdn`, or any other character, matched by what
  /// it types.
  factory KeyBinding.parse(
    String spec, {
    FieldRule fields = FieldRule.outside,
  }) => KeyBinding([
    for (final step in spec.split(' ')) _parseStroke(step),
  ], fields: fields);

  /// The strokes, in order.
  final List<KeyStroke> steps;

  /// Where it applies.
  final FieldRule fields;

  /// Whether its first stroke is a chord.
  bool get chorded => steps.first.chorded;

  /// How it reads: each stroke's label.
  List<String> get labels => [for (final s in steps) s.label];

  /// How it reads on one line: `g p`, `Ctrl K`.
  String get label => labels.join(' ');

  @override
  bool operator ==(Object other) =>
      other is KeyBinding &&
      other.fields == fields &&
      listEquals(other.steps, steps);

  @override
  int get hashCode => Object.hash(fields, Object.hashAll(steps));

  @override
  String toString() => label;
}

KeyStroke _parseStroke(String step) {
  final parts = step == '+' ? ['+'] : step.split('+');
  var control = false;
  var meta = false;
  var alt = false;
  var shift = false;
  for (final m in parts.take(parts.length - 1)) {
    switch (m) {
      case 'ctrl':
        control = true;
      case 'meta':
        meta = true;
      case 'alt':
        alt = true;
      case 'shift':
        shift = true;
      default:
        throw ArgumentError.value(step, 'step', 'unknown modifier $m');
    }
  }
  final key = parts.last;
  final named = _parseNames[key];
  if (named != null) {
    return KeyStroke(
      named,
      control: control,
      meta: meta,
      alt: alt,
      shift: shift,
    );
  }
  if (RegExp(r'^[a-zA-Z0-9]$').hasMatch(key)) {
    final upper = key.toUpperCase() == key && RegExp('[A-Z]').hasMatch(key);
    final logical = LogicalKeyboardKey.findKeyByKeyId(
      key.toLowerCase().codeUnitAt(0),
    )!;
    return KeyStroke(
      logical,
      control: control,
      meta: meta,
      alt: alt,
      shift: shift || upper,
    );
  }
  if (key.length == 1) {
    return KeyStroke.char(key, control: control, meta: meta, alt: alt);
  }
  throw ArgumentError.value(step, 'step', 'unknown key');
}

final Map<String, LogicalKeyboardKey> _parseNames = {
  'down': LogicalKeyboardKey.arrowDown,
  'up': LogicalKeyboardKey.arrowUp,
  'left': LogicalKeyboardKey.arrowLeft,
  'right': LogicalKeyboardKey.arrowRight,
  'esc': LogicalKeyboardKey.escape,
  'enter': LogicalKeyboardKey.enter,
  'space': LogicalKeyboardKey.space,
  'delete': LogicalKeyboardKey.delete,
  'home': LogicalKeyboardKey.home,
  'end': LogicalKeyboardKey.end,
  'pgdn': LogicalKeyboardKey.pageDown,
  'pgup': LogicalKeyboardKey.pageUp,
  'comma': LogicalKeyboardKey.comma,
  'period': LogicalKeyboardKey.period,
};

typedef _Table = Map<String, List<String>>;

/// Default: the app's keys, plus tix web's (`d` done, `g`/`G` and Home/End
/// jump, Esc back), plus `g` sequences and Ctrl+1 to Ctrl+6 for the
/// destinations, where tix's web and terminal interfaces have a sidebar.
const _base = <String, List<String>>{
  KeyActions.paletteOpen: ['ctrl+k', 'meta+k'],
  KeyActions.helpShow: ['?'],
  KeyActions.navBack: ['esc'],
  KeyActions.navProjects: ['g p', 'ctrl+1'],
  KeyActions.navTasks: ['g t', 'ctrl+2'],
  KeyActions.navMyWork: ['g m', 'ctrl+3'],
  KeyActions.navInbox: ['g i', 'ctrl+4'],
  KeyActions.navManage: ['g a', 'ctrl+5'],
  KeyActions.navSettings: ['g s', 'ctrl+6'],
  KeyActions.navWatch: ['g w'],
  KeyActions.quickAdd: ['ctrl+n', 'meta+n'],
  KeyActions.quickPaste: ['ctrl+shift+v', 'meta+shift+v'],
  KeyActions.listNext: ['down', 'j'],
  KeyActions.listPrev: ['up', 'k'],
  KeyActions.listTop: ['g', 'home'],
  KeyActions.listBottom: ['G', 'end'],
  KeyActions.listPageDown: ['pgdn'],
  KeyActions.listPageUp: ['pgup'],
  KeyActions.listOpen: ['enter'],
  KeyActions.listSelect: ['x'],
  KeyActions.listExtendDown: ['shift+down'],
  KeyActions.listExtendUp: ['shift+up'],
  KeyActions.listSelectAll: ['ctrl+a', 'meta+a'],
  KeyActions.listClear: ['esc'],
  KeyActions.listFilter: ['/'],
  KeyActions.listRefresh: ['r'],
  KeyActions.listView: ['v'],
  KeyActions.listNew: ['n'],
  KeyActions.listDone: ['e', 'd'],
  KeyActions.taskRename: ['e'],
  KeyActions.taskDescribe: ['d'],
  KeyActions.taskMove: ['m'],
  KeyActions.taskPriority: ['p'],
  KeyActions.taskAssign: ['a'],
  KeyActions.taskDue: ['u'],
  KeyActions.taskTag: ['t'],
  KeyActions.taskStar: ['s'],
  KeyActions.taskSnooze: ['z'],
  KeyActions.taskComment: ['c'],
  KeyActions.taskCopy: ['y'],
  KeyActions.taskDelete: ['delete'],
};

/// Bindings that apply inside a text field as well, or only there.
const _fieldRules = <String, FieldRule>{
  'ctrl+k': FieldRule.also,
  'meta+k': FieldRule.also,
};

const _leaveField = <KeymapPreset, List<String>>{
  KeymapPreset.standard: ['esc'],
  KeymapPreset.vim: ['esc'],
  KeymapPreset.emacs: ['esc', 'ctrl+g'],
};

/// What each preset rebinds away from Default, as tix's
/// `internal/tui/scheme.go` layers `schemeKeys` over its default map. An
/// action a preset does not name keeps its Default keys.
const _overrides = <KeymapPreset, _Table>{
  KeymapPreset.vim: {
    KeyActions.navBack: ['esc', 'h'],
    KeyActions.listTop: ['g g', 'home'],
    KeyActions.listPageDown: ['ctrl+d', 'ctrl+f', 'pgdn'],
    KeyActions.listPageUp: ['ctrl+u', 'ctrl+b', 'pgup'],
    KeyActions.listOpen: ['enter', 'l'],
    KeyActions.listSelect: ['v'],
    KeyActions.listExtendDown: ['J', 'shift+down'],
    KeyActions.listExtendUp: ['K', 'shift+up'],
    KeyActions.listView: ['g v'],
    KeyActions.listNew: ['o'],
    KeyActions.listDone: ['e'],
    KeyActions.taskRename: ['i'],
    KeyActions.taskDescribe: ['D'],
    KeyActions.taskDelete: ['d d', 'x', 'delete'],
  },
  // M-x is outside fields only: Option+X types a character on a Mac.
  KeymapPreset.emacs: {
    KeyActions.paletteOpen: ['ctrl+k', 'meta+k', 'alt+x'],
    KeyActions.navBack: ['esc', 'ctrl+g'],
    KeyActions.quickAdd: ['alt+n'],
    KeyActions.listNext: ['ctrl+n', 'down'],
    KeyActions.listPrev: ['ctrl+p', 'up'],
    KeyActions.listTop: ['alt+shift+comma', 'home'],
    KeyActions.listBottom: ['alt+shift+period', 'end'],
    KeyActions.listPageDown: ['ctrl+v', 'pgdn'],
    KeyActions.listPageUp: ['alt+v', 'pgup'],
    KeyActions.listSelect: ['ctrl+space', 'x'],
    KeyActions.listClear: ['esc', 'ctrl+g'],
    KeyActions.listFilter: ['ctrl+s', '/'],
    KeyActions.listRefresh: ['ctrl+l'],
  },
};

/// The keys every action has under one preset.
@immutable
class Keymap {
  const Keymap._(this.preset, this.enabled, this._table);

  /// The keymap of [preset], or none at all when not [enabled].
  factory Keymap.of(KeymapPreset preset, {bool enabled = true}) {
    if (!enabled) return Keymap._(preset, false, const {});
    final source = <String, List<String>>{..._base, ...?_overrides[preset]};
    final table = <String, List<KeyBinding>>{};
    for (final MapEntry(key: action, value: specs) in source.entries) {
      table[action] = [
        for (final spec in specs)
          KeyBinding.parse(
            spec,
            fields: _fieldRules[spec] ?? FieldRule.outside,
          ),
      ];
    }
    table[KeyActions.fieldLeave] = [
      for (final spec in _leaveField[preset] ?? const <String>[])
        KeyBinding.parse(spec, fields: FieldRule.only),
    ];
    if (preset == KeymapPreset.off) {
      for (final action in table.keys.toList()) {
        table[action] = [
          for (final b in table[action]!)
            if (b.chorded) b,
        ];
      }
    }
    return Keymap._(preset, true, table);
  }

  /// The preset it was built from.
  final KeymapPreset preset;

  /// Whether any shortcut is on.
  final bool enabled;

  final Map<String, List<KeyBinding>> _table;

  /// Every action it knows, in the order the help lists them.
  Iterable<String> get actions => _table.keys;

  /// The keys that run [action], first the one the help shows first.
  List<KeyBinding> bindingsFor(String action) => _table[action] ?? const [];

  /// The keys a command with no action and [shortcut] answers to: none while
  /// off, chords only under Off.
  List<KeyBinding> forShortcut(ShortcutActivator? shortcut) {
    if (!enabled || shortcut == null) return const [];
    final stroke = strokeOf(shortcut);
    if (stroke == null) return const [];
    if (preset == KeymapPreset.off && !stroke.chorded) return const [];
    return [
      KeyBinding([stroke]),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is Keymap && other.preset == preset && other.enabled == enabled;

  @override
  int get hashCode => Object.hash(preset, enabled);
}

/// The stroke [a] stands for, or null for an activator a keymap cannot
/// express.
KeyStroke? strokeOf(ShortcutActivator a) {
  if (a is CharacterActivator) {
    return KeyStroke.char(
      a.character,
      control: a.control,
      meta: a.meta,
      alt: a.alt,
    );
  }
  if (a is SingleActivator) {
    return KeyStroke(
      a.trigger,
      control: a.control,
      meta: a.meta,
      alt: a.alt,
      shift: a.shift,
    );
  }
  return null;
}

/// What feeding a key to a [KeySequencer] did.
sealed class KeyOutcome<T> {
  const KeyOutcome();
}

/// The key completed a binding: run [value].
final class KeyMatched<T> extends KeyOutcome<T> {
  /// Matched [value].
  const KeyMatched(this.value);

  /// What the binding runs.
  final T value;
}

/// The key started or continued a longer binding; wait for the next.
final class KeyPending<T> extends KeyOutcome<T> {
  /// Waiting.
  const KeyPending();
}

/// The key is no binding's.
final class KeyUnmatched<T> extends KeyOutcome<T> {
  /// Nothing.
  const KeyUnmatched();
}

/// Starts a timer; [Timer.new] outside tests.
typedef StartTimer = Timer Function(Duration duration, void Function() run);

/// Resolves key presses against bindings, one or two keys long. A key that
/// starts a longer binding waits up to [timeout] for the next; if the keys
/// so far also complete a binding, [onTimeout] gets that one when the wait
/// ends. Candidates come first-wins: the newest scope first.
class KeySequencer<T> {
  /// A sequencer that calls [onTimeout] with a binding that waited out
  /// [timeout].
  KeySequencer({
    required this.onTimeout,
    this.timeout = defaultTimeout,
    StartTimer? startTimer,
  }) : _startTimer = startTimer ?? Timer.new;

  /// One second, Vim's `timeoutlen`.
  static const defaultTimeout = Duration(seconds: 1);

  /// Runs a binding whose keys were a prefix of a longer one and waited.
  final void Function(T value) onTimeout;

  /// How long a prefix waits.
  final Duration timeout;

  final StartTimer _startTimer;
  List<KeyPress> _pending = const [];
  Timer? _timer;

  /// The keys waiting for the rest of a sequence.
  List<KeyPress> get pending => _pending;

  /// Forgets the waiting keys.
  void reset() {
    _timer?.cancel();
    _timer = null;
    _pending = const [];
  }

  /// Feeds [press], matching [candidates] in order.
  KeyOutcome<T> feed(KeyPress press, List<(KeyBinding, T)> candidates) {
    if (press.isModifier) {
      return _pending.isEmpty ? KeyUnmatched<T>() : KeyPending<T>();
    }
    _timer?.cancel();
    _timer = null;
    final typed = [..._pending, press];
    T? exact;
    var found = false;
    var longer = false;
    for (final (binding, value) in candidates) {
      if (!_prefix(binding.steps, typed)) continue;
      if (binding.steps.length == typed.length) {
        if (!found) {
          found = true;
          exact = value;
        }
      } else {
        longer = true;
      }
    }
    if (longer) {
      _pending = typed;
      _timer = _startTimer(timeout, () {
        _pending = const [];
        _timer = null;
        if (found) onTimeout(exact as T);
      });
      return KeyPending<T>();
    }
    _pending = const [];
    if (found) return KeyMatched<T>(exact as T);
    if (typed.length > 1) return feed(press, candidates);
    return KeyUnmatched<T>();
  }

  static bool _prefix(List<KeyStroke> steps, List<KeyPress> typed) {
    if (steps.length < typed.length) return false;
    for (var i = 0; i < typed.length; i++) {
      if (!steps[i].matches(typed[i])) return false;
    }
    return true;
  }
}
