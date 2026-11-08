## MODIFIED Requirements

### Requirement: A project's tasks are listed

The project screen SHALL show the project's tasks on the task screen, scoped to that project, with each task's
title, reference, status, due date and an icon for its priority that a screen reader names.

#### Scenario: Task row

- **WHEN** a project holds a task due on 20 November
- **THEN** its row shows the title and its reference, status and `Nov 20`

## ADDED Requirements

### Requirement: Projects show their colour and open work

Each project in the list SHALL carry its colour and the number of its tasks in open state categories, read
from `GET /api/v1/stats?project=KEY`. A count that cannot be read SHALL be left out.

#### Scenario: Open count

- **WHEN** a project has three tasks in todo or in progress and two done
- **THEN** its row shows 3
