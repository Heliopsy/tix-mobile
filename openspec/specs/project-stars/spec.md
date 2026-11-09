# project-stars Specification

## Purpose
A person stars the projects they use most: the stars are their own, listed first on the projects screen and in project pickers, kept in step with tix, and hidden on a server without them.

## Requirements

### Requirement: A project is starred from its row and its title

Each row of the projects list, and the project's name at the top of its tasks, SHALL carry a star toggle with a
label that says what it does. A star SHALL show at once, SHALL be put back with the server's reason when refused,
and SHALL offer Undo. Stars SHALL be read from `GET /api/v1/me/starred-projects` and changed with `PUT` and
`DELETE /api/v1/projects/{ref}/star`.

#### Scenario: Starring a project

- **WHEN** a person taps the star on Web in the projects list
- **THEN** Web moves to the Starred section at once and the server is asked to star it
- **AND** a toast says Web is starred, with Undo

#### Scenario: A refused star

- **WHEN** the server refuses the star with 403
- **THEN** the star is taken off again and the server's reason is shown

### Requirement: Starred projects are listed first, once

The projects list SHALL draw the reader's starred projects in a Starred section above the others, in the order
the server lists them, and SHALL leave them out of the list below so each project shows once. With the archived
filter off, archived starred projects SHALL be left out of the section too.

#### Scenario: One starred project

- **WHEN** the reader starred Web and opens the projects list
- **THEN** Web is listed under Starred, Infrastructure under Other projects, and Web is not listed again

### Requirement: Pickers offer starred projects first

The project switcher, the bulk copy picker, the quick add picker and the Project widget's picker SHALL list the
reader's starred projects before the others, keeping each group's own order, and the in-app pickers SHALL mark a
starred project with a star that a screen reader names.

#### Scenario: Quick add

- **WHEN** the reader starred Web and opens the quick add project picker
- **THEN** Web is offered before Infrastructure, with a star

### Requirement: A star is the reader's own

A star SHALL belong to the signed-in account in the active tenant: the app SHALL NOT show another person's
stars, and a context SHALL show only the stars read for it.

#### Scenario: Switching tenant

- **WHEN** the reader starred Web in Acme and switches to another tenant
- **THEN** the other tenant's projects show only the stars made there

### Requirement: Stars follow changes made elsewhere

The starred list SHALL be read again when a `project.*` event arrives, when a `view.arranged` event for the
`lanes` view arrives (a project star is its lane's star), and after the stream says events may have been missed.

#### Scenario: Starred on the web

- **WHEN** the reader stars Infrastructure in tix's web interface while the app is open
- **THEN** Infrastructure joins the Starred section without a pull to refresh

### Requirement: No stars on a server without them

When `GET /api/v1/me/starred-projects` answers 404 or 405 the app SHALL draw no star toggle, no Starred section
and no star in pickers, and SHALL otherwise list projects as before.

#### Scenario: An older tix

- **WHEN** the app is connected to a tix that predates project stars
- **THEN** the projects list has no star toggles and no Starred section
