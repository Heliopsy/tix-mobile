# task-browsing Specification

## Purpose
Reading the active server's projects, a project's tasks and one task in full.

## Requirements

### Requirement: Projects are listed

The app SHALL list the active server's projects from `GET /api/v1/projects`, showing each project's name
and key, and SHALL open a project's tasks when one is tapped.

#### Scenario: Opening a project

- **WHEN** a person taps a project
- **THEN** the app shows that project's tasks

### Requirement: Lists follow the server's keyset pagination

Every list SHALL request pages with `limit` and pass each page's `next_cursor` back as `cursor`, stopping when
`next_cursor` is empty or absent. The next page SHALL be requested as the end of the list comes into view.
A failed next page SHALL keep the rows already shown and offer a retry.

#### Scenario: Scrolling to the end

- **WHEN** a list has more rows than one page and a person scrolls to its end
- **THEN** the app requests the next page with the previous page's cursor and appends it

#### Scenario: Next page fails

- **WHEN** the next page request fails
- **THEN** the loaded rows stay and the list's footer says so with a retry button

### Requirement: Lists refresh on pull

A pull-down on any list SHALL reload it from the first page.

#### Scenario: New project appears

- **WHEN** a project is created elsewhere and a person pulls the projects list down
- **THEN** the new project appears

### Requirement: A project's tasks are listed

The app SHALL list a project's tasks from `GET /api/v1/tasks?project=KEY` in the server's default order,
each with its title, reference, status, due date and an icon for its priority that a screen reader names.

#### Scenario: Task row

- **WHEN** a project holds a task due on 20 November
- **THEN** its row shows the title and its reference, status and `Nov 20`

### Requirement: A task is shown in full

The task view SHALL show the title, status, priority, assignee by name, due date, tags and description. The
description SHALL be drawn as Markdown. A missing assignee, due date or description SHALL be stated.

#### Scenario: Assignee by name

- **WHEN** a task is assigned to an actor whose display name is Raj
- **THEN** the task view shows Raj, and the actor's id until the name has loaded
