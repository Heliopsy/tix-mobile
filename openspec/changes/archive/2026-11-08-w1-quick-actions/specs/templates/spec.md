## ADDED Requirements

### Requirement: Templates are listed

The templates screen SHALL list the templates the person can read, by name, a page at a time, each with its
project (or "every project"), its title and how often it was used, and SHALL say when there are none.

#### Scenario: Templates listed

- **WHEN** the server holds templates `weekly` in `ops` and `bug` for every project
- **THEN** both are listed with their project and title

#### Scenario: None

- **WHEN** the server holds no template
- **THEN** the screen says so and offers New template

### Requirement: A task is saved as a template

New template SHALL save a task, chosen by reference, as a template with a name through `template.save`, optionally
with its subtasks, shared with every project, and with a due offset. A name the server refuses SHALL keep the form
open with the server's reason.

#### Scenario: Saved

- **WHEN** a person saves `ops-3` as `weekly` with subtasks
- **THEN** the request names `ops-3`, `weekly` and `with_subtasks: true`, and `weekly` is listed

#### Scenario: Name taken

- **WHEN** the server answers `409`
- **THEN** the form stays open with the message

### Requirement: A template starts from a new task

New template SHALL offer to start from scratch: a quick-add line creates the task in the chosen project and the
task is then saved as the template. The form SHALL say that the task stays in the project.

#### Scenario: From scratch

- **WHEN** a person names a template `standup` from the line `Standup notes #team`
- **THEN** a task is created from that line and saved as `standup`

### Requirement: A template is edited and deleted

A template's sheet SHALL edit its name, title, description, priority, tags, recurrence, due offset and project
through `template.update`, sending only what changed, and SHALL delete it after a confirmation through
`template.delete`.

#### Scenario: Renamed

- **WHEN** a person renames `weekly` to `weekly-review`
- **THEN** the request carries only the new name

#### Scenario: Deleted

- **WHEN** a person deletes `weekly` and confirms
- **THEN** `weekly` is no longer listed

### Requirement: A task comes from a template in one tap

Use on a template SHALL create a task through `template.use` at once and confirm it with its reference and a way to
open it. Quick add SHALL list the most used templates so one tap creates a task from one.

#### Scenario: Used

- **WHEN** a person taps Use on `weekly`
- **THEN** a task is created and the app says `Created ops-12` with Open
