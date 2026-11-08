// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'widget_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetContext _$WidgetContextFromJson(Map<String, dynamic> json) =>
    WidgetContext(
      id: json['id'] as String,
      instance: json['instance'] as String,
      tenant: json['tenant'] as String,
      local: json['local'] as bool? ?? false,
    );

Map<String, dynamic> _$WidgetContextToJson(WidgetContext instance) =>
    <String, dynamic>{
      'id': instance.id,
      'instance': instance.instance,
      'tenant': instance.tenant,
      'local': instance.local,
    };

WidgetColour _$WidgetColourFromJson(Map<String, dynamic> json) =>
    WidgetColour(light: json['light'] as String, dark: json['dark'] as String);

Map<String, dynamic> _$WidgetColourToJson(WidgetColour instance) =>
    <String, dynamic>{'light': instance.light, 'dark': instance.dark};

WidgetAccent _$WidgetAccentFromJson(Map<String, dynamic> json) => WidgetAccent(
  light: json['light'] as String,
  dark: json['dark'] as String,
  onLight: json['onLight'] as String,
  onDark: json['onDark'] as String,
);

Map<String, dynamic> _$WidgetAccentToJson(WidgetAccent instance) =>
    <String, dynamic>{
      'light': instance.light,
      'dark': instance.dark,
      'onLight': instance.onLight,
      'onDark': instance.onDark,
    };

WidgetTask _$WidgetTaskFromJson(Map<String, dynamic> json) => WidgetTask(
  ref: json['ref'] as String,
  title: json['title'] as String,
  project: json['project'] as String,
  priority: json['priority'] as String,
  status: json['status'] as String,
  category: json['category'] as String,
  route: json['route'] as String,
  colour: json['colour'] == null
      ? null
      : WidgetColour.fromJson(json['colour'] as Map<String, dynamic>),
  due: (json['due'] as num?)?.toInt(),
);

Map<String, dynamic> _$WidgetTaskToJson(WidgetTask instance) =>
    <String, dynamic>{
      'ref': instance.ref,
      'title': instance.title,
      'project': instance.project,
      'colour': ?instance.colour?.toJson(),
      'due': ?instance.due,
      'priority': instance.priority,
      'status': instance.status,
      'category': instance.category,
      'route': instance.route,
    };

WidgetInboxItem _$WidgetInboxItemFromJson(Map<String, dynamic> json) =>
    WidgetInboxItem(
      id: json['id'] as String,
      what: json['what'] as String,
      task: json['task'] as String,
      excerpt: json['excerpt'] as String,
      route: json['route'] as String,
      at: (json['at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WidgetInboxItemToJson(WidgetInboxItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'what': instance.what,
      'task': instance.task,
      'excerpt': instance.excerpt,
      'at': ?instance.at,
      'route': instance.route,
    };

WidgetProject _$WidgetProjectFromJson(Map<String, dynamic> json) =>
    WidgetProject(
      key: json['key'] as String,
      name: json['name'] as String,
      colour: json['colour'] == null
          ? null
          : WidgetColour.fromJson(json['colour'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WidgetProjectToJson(WidgetProject instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'colour': ?instance.colour?.toJson(),
    };

WidgetGroup _$WidgetGroupFromJson(Map<String, dynamic> json) => WidgetGroup(
  status: json['status'] as String,
  label: json['label'] as String,
  category: json['category'] as String,
  count: (json['count'] as num).toInt(),
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => WidgetTask.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WidgetGroupToJson(WidgetGroup instance) =>
    <String, dynamic>{
      'status': instance.status,
      'label': instance.label,
      'category': instance.category,
      'count': instance.count,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };

MyWorkSnapshot _$MyWorkSnapshotFromJson(Map<String, dynamic> json) =>
    MyWorkSnapshot(
      at: (json['at'] as num).toInt(),
      ctx: WidgetContext.fromJson(json['ctx'] as Map<String, dynamic>),
      accent: WidgetAccent.fromJson(json['accent'] as Map<String, dynamic>),
      total: (json['total'] as num).toInt(),
      more: json['more'] as bool,
      moreText: json['moreText'] as String,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => WidgetTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      v: (json['v'] as num?)?.toInt() ?? widgetSchemaVersion,
    );

Map<String, dynamic> _$MyWorkSnapshotToJson(MyWorkSnapshot instance) =>
    <String, dynamic>{
      'v': instance.v,
      'at': instance.at,
      'ctx': instance.ctx.toJson(),
      'accent': instance.accent.toJson(),
      'total': instance.total,
      'more': instance.more,
      'moreText': instance.moreText,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
    };

InboxSnapshot _$InboxSnapshotFromJson(Map<String, dynamic> json) =>
    InboxSnapshot(
      at: (json['at'] as num).toInt(),
      ctx: WidgetContext.fromJson(json['ctx'] as Map<String, dynamic>),
      accent: WidgetAccent.fromJson(json['accent'] as Map<String, dynamic>),
      unread: (json['unread'] as num).toInt(),
      more: json['more'] as bool,
      unreadText: json['unreadText'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => WidgetInboxItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      v: (json['v'] as num?)?.toInt() ?? widgetSchemaVersion,
    );

Map<String, dynamic> _$InboxSnapshotToJson(InboxSnapshot instance) =>
    <String, dynamic>{
      'v': instance.v,
      'at': instance.at,
      'ctx': instance.ctx.toJson(),
      'accent': instance.accent.toJson(),
      'unread': instance.unread,
      'more': instance.more,
      'unreadText': instance.unreadText,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ProjectSnapshot _$ProjectSnapshotFromJson(Map<String, dynamic> json) =>
    ProjectSnapshot(
      at: (json['at'] as num).toInt(),
      ctx: WidgetContext.fromJson(json['ctx'] as Map<String, dynamic>),
      accent: WidgetAccent.fromJson(json['accent'] as Map<String, dynamic>),
      project: WidgetProject.fromJson(json['project'] as Map<String, dynamic>),
      open: (json['open'] as num).toInt(),
      more: json['more'] as bool,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => WidgetGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      v: (json['v'] as num?)?.toInt() ?? widgetSchemaVersion,
    );

Map<String, dynamic> _$ProjectSnapshotToJson(ProjectSnapshot instance) =>
    <String, dynamic>{
      'v': instance.v,
      'at': instance.at,
      'ctx': instance.ctx.toJson(),
      'accent': instance.accent.toJson(),
      'project': instance.project.toJson(),
      'open': instance.open,
      'more': instance.more,
      'groups': instance.groups.map((e) => e.toJson()).toList(),
    };

WidgetIndex _$WidgetIndexFromJson(Map<String, dynamic> json) => WidgetIndex(
  at: (json['at'] as num).toInt(),
  active: json['active'] as String?,
  contexts: (json['contexts'] as List<dynamic>)
      .map((e) => WidgetContext.fromJson(e as Map<String, dynamic>))
      .toList(),
  projects: (json['projects'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => WidgetProject.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  theme: json['theme'] as String,
  systemBlack: json['systemBlack'] as bool,
  lockCounts: json['lockCounts'] as bool,
  strings: Map<String, String>.from(json['strings'] as Map),
  v: (json['v'] as num?)?.toInt() ?? widgetSchemaVersion,
);

Map<String, dynamic> _$WidgetIndexToJson(WidgetIndex instance) =>
    <String, dynamic>{
      'v': instance.v,
      'at': instance.at,
      'active': ?instance.active,
      'contexts': instance.contexts.map((e) => e.toJson()).toList(),
      'projects': instance.projects.map(
        (k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()),
      ),
      'theme': instance.theme,
      'systemBlack': instance.systemBlack,
      'lockCounts': instance.lockCounts,
      'strings': instance.strings,
    };

WidgetAction _$WidgetActionFromJson(Map<String, dynamic> json) => WidgetAction(
  id: json['id'] as String,
  op: json['op'] as String,
  ctx: json['ctx'] as String,
  ref: json['ref'] as String,
  at: (json['at'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WidgetActionToJson(WidgetAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'op': instance.op,
      'ctx': instance.ctx,
      'ref': instance.ref,
      'at': instance.at,
    };

WidgetWant _$WidgetWantFromJson(Map<String, dynamic> json) => WidgetWant(
  ctx: json['ctx'] as String,
  project: json['project'] as String?,
  at: (json['at'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WidgetWantToJson(WidgetWant instance) =>
    <String, dynamic>{
      'ctx': instance.ctx,
      'project': ?instance.project,
      'at': instance.at,
    };
