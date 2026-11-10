// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/data/query/task_query.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

/// The tasks of one project, as a list or its board; on wide screens beside
/// the selected task.
class TaskListScreen extends StatelessWidget {
  /// Lists the tasks of [projectKey], highlighting [selectedRef].
  const TaskListScreen({required this.projectKey, this.selectedRef, super.key});

  /// The project's key.
  final String projectKey;

  /// The task open beside the list on wide screens.
  final String? selectedRef;

  @override
  Widget build(BuildContext context) =>
      TaskScreenView(scope: ProjectScope(projectKey), selectedRef: selectedRef);
}
