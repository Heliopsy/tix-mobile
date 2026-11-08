// SPDX-License-Identifier: AGPL-3.0-or-later

/// What the app hands its home screen widgets, as `docs/widgets.md` defines
/// it. Nothing here has a field for a credential or a server address.
library;

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'widget_snapshot.g.dart';

/// The snapshot format; widgets refuse any other.
const widgetSchemaVersion = 1;

/// Where each snapshot is stored in widget storage.
abstract final class WidgetKeys {
  /// The index: contexts, projects, theme, privacy and labels.
  static const index = 'tix.widget.index';

  /// Actions widgets queued for the app.
  static const queue = 'tix.widget.queue';

  /// What configured widgets need written.
  static const wanted = 'tix.widget.wanted';

  /// My work in [ctx].
  static String myWork(String ctx) => 'tix.widget.mywork.$ctx';

  /// The inbox in [ctx].
  static String inbox(String ctx) => 'tix.widget.inbox.$ctx';

  /// The project [key] in [ctx].
  static String project(String ctx, String key) =>
      'tix.widget.project.$ctx.$key';

  /// A widget's context that follows whichever is active.
  static const active = 'active';
}

/// A context as a widget names it: the instance and tenant, no address.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetContext {
  /// The context [id], shown as [instance] and [tenant].
  const WidgetContext({
    required this.id,
    required this.instance,
    required this.tenant,
    this.local = false,
  });

  /// Reads one back.
  factory WidgetContext.fromJson(Map<String, dynamic> json) =>
      _$WidgetContextFromJson(json);

  /// `<connectionId>.<tenantKey>`.
  final String id;

  /// The instance's name.
  final String instance;

  /// The tenant's name.
  final String tenant;

  /// Whether the instance is a database served on this device.
  final bool local;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetContextToJson(this);
}

/// A colour in the light and the dark scheme, `#rrggbb`.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetColour {
  /// [light] and [dark].
  const WidgetColour({required this.light, required this.dark});

  /// Reads one back.
  factory WidgetColour.fromJson(Map<String, dynamic> json) =>
      _$WidgetColourFromJson(json);

  /// On the light page.
  final String light;

  /// On the dark and OLED pages.
  final String dark;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetColourToJson(this);
}

/// The tenant's accent and the text that reads on it.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetAccent {
  /// Every colour given.
  const WidgetAccent({
    required this.light,
    required this.dark,
    required this.onLight,
    required this.onDark,
  });

  /// Reads one back.
  factory WidgetAccent.fromJson(Map<String, dynamic> json) =>
      _$WidgetAccentFromJson(json);

  /// The accent in the light scheme.
  final String light;

  /// The accent in the dark schemes.
  final String dark;

  /// Text on [light].
  final String onLight;

  /// Text on [dark].
  final String onDark;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetAccentToJson(this);
}

/// A task row.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetTask {
  /// A row for [ref].
  const WidgetTask({
    required this.ref,
    required this.title,
    required this.project,
    required this.priority,
    required this.status,
    required this.category,
    required this.route,
    this.colour,
    this.due,
  });

  /// Reads one back.
  factory WidgetTask.fromJson(Map<String, dynamic> json) =>
      _$WidgetTaskFromJson(json);

  /// The reference, such as OPS-12.
  final String ref;

  /// The title.
  final String title;

  /// The project's key.
  final String project;

  /// The project's colour, when it has one.
  final WidgetColour? colour;

  /// When it is due, in milliseconds since the epoch.
  final int? due;

  /// `highest`, `high`, `normal`, `low` or `lowest`.
  final String priority;

  /// The state's label.
  final String status;

  /// `todo`, `doing`, `blocked`, `waiting`, `done` or `cancelled`.
  final String category;

  /// The app route that opens it.
  final String route;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetTaskToJson(this);
}

/// An inbox row.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetInboxItem {
  /// The item [id].
  const WidgetInboxItem({
    required this.id,
    required this.what,
    required this.task,
    required this.excerpt,
    required this.route,
    this.at,
  });

  /// Reads one back.
  factory WidgetInboxItem.fromJson(Map<String, dynamic> json) =>
      _$WidgetInboxItemFromJson(json);

  /// The item's id, to mark it read.
  final String id;

  /// Who did what, translated.
  final String what;

  /// The task's reference and title.
  final String task;

  /// The quoted comment or change.
  final String excerpt;

  /// When, in milliseconds since the epoch.
  final int? at;

  /// The app route that opens it.
  final String route;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetInboxItemToJson(this);
}

/// A project as the pickers and the Project widget name it.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetProject {
  /// The project [key].
  const WidgetProject({required this.key, required this.name, this.colour});

  /// Reads one back.
  factory WidgetProject.fromJson(Map<String, dynamic> json) =>
      _$WidgetProjectFromJson(json);

  /// Its key.
  final String key;

  /// Its name.
  final String name;

  /// Its colour, when it has one.
  final WidgetColour? colour;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetProjectToJson(this);
}

/// The tasks in one state of a project.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetGroup {
  /// The state [status].
  const WidgetGroup({
    required this.status,
    required this.label,
    required this.category,
    required this.count,
    required this.tasks,
  });

  /// Reads one back.
  factory WidgetGroup.fromJson(Map<String, dynamic> json) =>
      _$WidgetGroupFromJson(json);

  /// The state's key.
  final String status;

  /// The state's label.
  final String label;

  /// Its category, as on [WidgetTask].
  final String category;

  /// How many tasks were read in it.
  final int count;

  /// The first few.
  final List<WidgetTask> tasks;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetGroupToJson(this);
}

/// The My work widget's data.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class MyWorkSnapshot {
  /// Every field given.
  const MyWorkSnapshot({
    required this.at,
    required this.ctx,
    required this.accent,
    required this.total,
    required this.more,
    required this.moreText,
    required this.tasks,
    this.v = widgetSchemaVersion,
  });

  /// Reads one back.
  factory MyWorkSnapshot.fromJson(Map<String, dynamic> json) =>
      _$MyWorkSnapshotFromJson(json);

  /// The format.
  final int v;

  /// When it was written, in milliseconds since the epoch.
  final int at;

  /// Whose it is.
  final WidgetContext ctx;

  /// The tenant's accent.
  final WidgetAccent accent;

  /// How many open tasks are assigned, at least.
  final int total;

  /// Whether there are more than [total].
  final bool more;

  /// "+9 more", translated.
  final String moreText;

  /// The next tasks.
  final List<WidgetTask> tasks;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$MyWorkSnapshotToJson(this);
}

/// The Inbox widget's data.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class InboxSnapshot {
  /// Every field given.
  const InboxSnapshot({
    required this.at,
    required this.ctx,
    required this.accent,
    required this.unread,
    required this.more,
    required this.unreadText,
    required this.items,
    this.v = widgetSchemaVersion,
  });

  /// Reads one back.
  factory InboxSnapshot.fromJson(Map<String, dynamic> json) =>
      _$InboxSnapshotFromJson(json);

  /// The format.
  final int v;

  /// When it was written.
  final int at;

  /// Whose it is.
  final WidgetContext ctx;

  /// The tenant's accent.
  final WidgetAccent accent;

  /// Unread items.
  final int unread;

  /// Whether [unread] is a floor.
  final bool more;

  /// "5 unread", translated.
  final String unreadText;

  /// The newest unread items.
  final List<WidgetInboxItem> items;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$InboxSnapshotToJson(this);
}

/// The Project widget's data.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class ProjectSnapshot {
  /// Every field given.
  const ProjectSnapshot({
    required this.at,
    required this.ctx,
    required this.accent,
    required this.project,
    required this.open,
    required this.more,
    required this.groups,
    this.v = widgetSchemaVersion,
  });

  /// Reads one back.
  factory ProjectSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ProjectSnapshotFromJson(json);

  /// The format.
  final int v;

  /// When it was written.
  final int at;

  /// Whose it is.
  final WidgetContext ctx;

  /// The tenant's accent.
  final WidgetAccent accent;

  /// The project.
  final WidgetProject project;

  /// Open tasks read.
  final int open;

  /// Whether there are more than [open].
  final bool more;

  /// One per unfinished state, in workflow order.
  final List<WidgetGroup> groups;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$ProjectSnapshotToJson(this);
}

/// What every widget reads first.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetIndex {
  /// Every field given.
  const WidgetIndex({
    required this.at,
    required this.active,
    required this.contexts,
    required this.projects,
    required this.theme,
    required this.systemBlack,
    required this.lockCounts,
    required this.strings,
    this.v = widgetSchemaVersion,
  });

  /// Reads one back.
  factory WidgetIndex.fromJson(Map<String, dynamic> json) =>
      _$WidgetIndexFromJson(json);

  /// The format.
  final int v;

  /// When it was written.
  final int at;

  /// The active context, null when signed out.
  final String? active;

  /// Every saved context.
  final List<WidgetContext> contexts;

  /// Projects per context, for the pickers.
  final Map<String, List<WidgetProject>> projects;

  /// `system`, `light`, `dark` or `black`.
  final String theme;

  /// Whether the system's dark is OLED black.
  final bool systemBlack;

  /// Whether the lock screen shows counts only.
  final bool lockCounts;

  /// Labels in the app's language.
  final Map<String, String> strings;

  /// The JSON a widget reads.
  Map<String, dynamic> toJson() => _$WidgetIndexToJson(this);
}

/// One action a widget queued.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetAction {
  /// The action [id].
  const WidgetAction({
    required this.id,
    required this.op,
    required this.ctx,
    required this.ref,
    this.at = 0,
  });

  /// Reads one a widget wrote.
  factory WidgetAction.fromJson(Map<String, dynamic> json) =>
      _$WidgetActionFromJson(json);

  /// The completing operation.
  static const complete = 'complete';

  /// Unique per tap.
  final String id;

  /// What to do; only [complete] so far.
  final String op;

  /// The context, never [WidgetKeys.active].
  final String ctx;

  /// The task.
  final String ref;

  /// When it was tapped.
  final int at;

  /// The JSON stored.
  Map<String, dynamic> toJson() => _$WidgetActionToJson(this);
}

/// What one configured widget needs written.
@immutable
@JsonSerializable(fieldRename: FieldRename.none)
class WidgetWant {
  /// [ctx], and [project] in it when given.
  const WidgetWant({required this.ctx, this.project, this.at = 0});

  /// Reads one a widget wrote.
  factory WidgetWant.fromJson(Map<String, dynamic> json) =>
      _$WidgetWantFromJson(json);

  /// The context, or [WidgetKeys.active].
  final String ctx;

  /// A project key, for the Project widget.
  final String? project;

  /// When the widget last said so.
  final int at;

  /// The JSON stored.
  Map<String, dynamic> toJson() => _$WidgetWantToJson(this);
}
