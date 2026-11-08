// SPDX-License-Identifier: AGPL-3.0-or-later

/// What managing projects, workflows and custom fields reads and sends, as
/// the generated client names it, and tix's fixed vocabularies for them.
library;

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        CreateProjectInput,
        FieldDef,
        FieldDefInput,
        FieldType,
        Project,
        ProjectDeletion,
        ProjectIconFile,
        Scope,
        StateCategory,
        StatusMove,
        Transition,
        UpdateProjectInput,
        Workflow,
        WorkflowDefinition,
        WorkflowInput;
export 'package:tix_mobile/src/data/models/task_detail.dart'
    show StateNames, WorkflowRoute, WorkflowRoutes, WorkflowState;

/// tix's built-in project icons, in the order its picker shows them
/// (`core/projecticon.go`).
const projectIconNames = <String>[
  'folder',
  'briefcase',
  'home',
  'server',
  'database',
  'cloud',
  'code',
  'terminal',
  'bug',
  'rocket',
  'shield',
  'lock',
  'globe',
  'chart',
  'book',
  'users',
  'package',
  'wrench',
  'flask',
  'bolt',
];

/// The largest icon image tix accepts, in bytes.
const int maxProjectIconBytes = 64 * 1024;

/// A project key tix accepts: a letter first, a letter or digit last, and
/// letters, digits, `-` and `_` between, at most 64 (`core/ref.go`).
///
/// Only for suggesting a key from a name; the server decides what it takes.
String suggestProjectKey(String name) {
  final words = name
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('^[^a-z]+'), '')
      .replaceAll(RegExp(r'-+$'), '');
  return words.length > 64
      ? words.substring(0, 64).replaceAll(RegExp(r'[-_]+$'), '')
      : words;
}
