// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// A change to some of a task's attributes: the body of `PATCH /tasks/{ref}`.
///
/// A key that is absent leaves the attribute alone; a JSON null clears it.
/// The same change applies to a local [Task], and [inverseFor] builds the
/// change that undoes it, so an optimistic edit and its Undo are symmetrical.
@immutable
class TaskPatch {
  const TaskPatch._(this._fields);

  /// Renames the task.
  TaskPatch.title(String title) : this._({'title': title});

  /// Replaces the Markdown description.
  TaskPatch.body(String body) : this._({'body': body});

  /// Sets the priority, 1 the highest and 5 the lowest.
  TaskPatch.priority(int priority) : this._({'priority': priority});

  /// Assigns the actor [actorId]; empty unassigns.
  TaskPatch.assignee(String actorId) : this._({'assignee_actor_id': actorId});

  /// Sets the due time, or clears it when [due] is null.
  TaskPatch.due(DateTime? due)
    : this._({'due_at': due?.toUtc().toIso8601String()});

  /// Replaces the whole tag set.
  TaskPatch.tags(List<String> tags) : this._({'tags': tags});

  /// Replaces the repeat rule; empty removes it.
  TaskPatch.recurrence(String rule) : this._({'recurrence': rule});

  /// Sets the custom field [key], or clears it when [value] is null.
  TaskPatch.field(String key, Object? value)
    : this._({
        'custom_fields': {key: value},
      });

  /// Moves the task under [parentRef]; empty detaches it.
  TaskPatch.parent(String parentRef) : this._({'parent_ref': parentRef});

  final Map<String, Object?> _fields;

  /// The attributes this change names, as their JSON keys.
  Iterable<String> get keys => _fields.keys;

  /// The JSON body.
  Map<String, Object?> toJson() => {..._fields};

  /// The body as the generated client sends it. It cannot carry a JSON null,
  /// so a cleared due date is [clearsDue] instead.
  UpdateTaskInput toInput({int? version}) =>
      UpdateTaskInput.fromJson({..._fields, 'version': ?version});

  /// Whether the change clears the due date, which needs `"due_at": null`.
  bool get clearsDue =>
      _fields.containsKey('due_at') && _fields['due_at'] == null;

  /// [task] as it would be after the change.
  Task applyTo(Task task) {
    var t = task;
    for (final MapEntry(:key, :value) in _fields.entries) {
      t = switch (key) {
        'title' => t.copyWith(title: value! as String),
        'body' => t.copyWith(body: value! as String),
        'priority' => t.copyWith(priority: value! as int),
        'assignee_actor_id' => t.copyWith(assigneeActorId: value! as String),
        'due_at' => t.copyWith(
          dueAt: value == null ? null : DateTime.parse(value as String),
        ),
        'tags' => t.copyWith(tags: List.unmodifiable(value! as List<String>)),
        'recurrence' => t.copyWith(recurrence: value! as String),
        'custom_fields' => t.copyWith(
          customFields: _mergeFields(
            t.customFields,
            value! as Map<String, Object?>,
          ),
        ),
        _ => t,
      };
    }
    return t;
  }

  /// The change that puts [before]'s values back.
  TaskPatch inverseFor(Task before) => TaskPatch._({
    for (final key in _fields.keys)
      ...switch (key) {
        'title' => {'title': before.title},
        'body' => {'body': before.body},
        'priority' => {'priority': before.priority},
        'assignee_actor_id' => {'assignee_actor_id': before.assigneeActorId},
        'due_at' => {'due_at': before.dueAt?.toUtc().toIso8601String()},
        'tags' => {'tags': before.tags},
        'recurrence' => {'recurrence': before.recurrence},
        'custom_fields' => {
          'custom_fields': {
            for (final k in (_fields[key]! as Map<String, Object?>).keys)
              k: before.customFields[k],
          },
        },
        _ => const <String, Object?>{},
      },
  });

  static Map<String, Object?> _mergeFields(
    Map<String, Object?> stored,
    Map<String, Object?> change,
  ) {
    final merged = {...stored};
    for (final MapEntry(:key, :value) in change.entries) {
      if (value == null) {
        merged.remove(key);
      } else {
        merged[key] = value;
      }
    }
    return Map.unmodifiable(merged);
  }

  @override
  bool operator ==(Object other) =>
      other is TaskPatch && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => 'TaskPatch($_fields)';
}
