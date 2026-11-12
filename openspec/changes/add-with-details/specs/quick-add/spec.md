# quick-add

## ADDED Requirements

### Requirement: Add with details

The app SHALL offer an "Add with details" form with the fields of tix's web form: title, description, project,
priority, due date, assignee, tags, and under More options the repeat rule, parent task, dependencies and lease.
It SHALL send `POST /api/v1/tasks` with those fields structured, without `parse`, and SHALL leave empty fields out.

#### Scenario: Every field

- **WHEN** a person fills in the title `Fix login !high`, tags `auth, ui`, depends on `web-2, web-3` and lease `2h`
  in project `web` and creates the task
- **THEN** the request carries that title as typed, `tags: [auth, ui]`, `depends_on: [web-2, web-3]`,
  `lease: 2h`, `project_ref: web` and no `parse`

#### Scenario: No title

- **WHEN** a person creates the task with an empty title
- **THEN** nothing is sent and the form says a task needs a title

### Requirement: Quick add hands over to Add with details

Quick add SHALL offer "More details", which SHALL close quick add and open Add with details holding the typed line
as the title and the project quick add had chosen.

#### Scenario: More details

- **WHEN** a person types `Renew cert` in quick add for project `web` and presses More details
- **THEN** Add with details opens with the title `Renew cert` and creating it sends `project_ref: web`

### Requirement: A refused form keeps its values

When the server refuses Add with details, the form SHALL stay open with every value. A refusal whose details name a
field SHALL be shown under that field; any other refusal SHALL be shown above the form.

#### Scenario: Lease refused

- **WHEN** the server answers `400` naming the field `lease`
- **THEN** its message is shown under the lease field and the title is kept

### Requirement: Add with details without a network

When the server cannot be reached, Add with details SHALL queue the task as a draft to send later, as quick add
does.

#### Scenario: Offline

- **WHEN** a person creates a task in `infra` with no network
- **THEN** the form closes on the draft `infra-draft1`
