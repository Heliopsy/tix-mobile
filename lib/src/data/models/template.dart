// SPDX-License-Identifier: AGPL-3.0-or-later

/// Task templates, as the generated client reads and writes them.
library;

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        SaveTemplateInput,
        TaskTemplate,
        TemplateTask,
        UpdateTemplateInput,
        UseTemplateInput;

/// What the app reads off a template.
extension TaskTemplateFacts on TaskTemplate {
  /// The task shape a use creates, empty when the server sent none.
  TemplateTask get shape => task ?? const TemplateTask();

  /// Whether every project shares it.
  bool get tenantWide => projectKey.isEmpty && projectId.isEmpty;

  /// How many tasks a use creates beside the root.
  int get subtaskCount => shape.descendants;
}

/// What the app reads off a template's task shape.
extension TemplateTaskFacts on TemplateTask {
  /// Every subtask below this one, at any depth.
  int get descendants =>
      subtasks.fold(subtasks.length, (n, s) => n + s.descendants);
}

/// Whether [request] changes nothing.
bool isEmptyUpdate(UpdateTemplateInput request) => request.toJson().isEmpty;
