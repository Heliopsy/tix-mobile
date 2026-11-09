## ADDED Requirements

### Requirement: Switching drops the old context's screens

A move to another context SHALL take down every screen, tab stack, sheet and dialog of the old one before the new
one is active, so none asks the new context for an id of the old. Without a target the app SHALL land on the root
of the tab that was showing; the instances and about screens MAY stay. Every other tab SHALL open at its root.

#### Scenario: Switching tenant on a task

- **WHEN** a person on `/projects/infra/tasks/infra-1`, with a workflow open under Manage, switches to tenant Acme
- **THEN** the projects list of Acme shows and no request for `infra` reaches Acme
- **AND** opening Manage shows its root, not the workflow

#### Scenario: A switch closes the old sheets

- **WHEN** a sheet and a dialog are open over a task and the context changes
- **THEN** both are closed

### Requirement: A switch with a target lands on it

A switch made to open something, such as a `tix://` link naming a context, ADB `open` or a home screen widget, SHALL
land on that target in the new context, with every other tab at its root. Activating the active context again,
or the session reloading with the same context, SHALL keep the screen and every tab as they are.

#### Scenario: A link into another tenant

- **WHEN** `tix://projects/ops?context=s1.acme` opens while the person is on a task of tenant Default
- **THEN** the app switches to Acme and shows the tasks of `ops`

#### Scenario: The same context again

- **WHEN** the person activates the context they are in, or the session reloads
- **THEN** the task stays open and the other tabs keep their screens
