# statistics

## ADDED Requirements

### Requirement: Statistics destination

The app SHALL offer Statistics as a destination after Activity and in the command palette. It SHALL read
`GET /stats` for a window of 7, 14, 30 or 90 days ending now, 14 by default, and for every project or one.

#### Scenario: Default window

- **WHEN** a person opens Statistics
- **THEN** the app reads `GET /stats` with `window=336h` and no project

#### Scenario: Narrowed

- **WHEN** the person picks 30 days and the project infra
- **THEN** the app reads `GET /stats` with `window=720h` and `project=infra`

### Requirement: Statistics figures

Statistics SHALL show completed, created, median lead time and slowest lead time, completed per day, the tasks in
each state category now, the leaderboard with what it counts, and the open tasks waiting longest. Each part SHALL
say so in words when it has nothing to show.

#### Scenario: Figures

- **WHEN** the server answers 4 completed, 6 created and a median lead time of 36h
- **THEN** the screen shows 4 completed, 6 created and a median of 1 d 12 h

#### Scenario: Nothing completed

- **WHEN** no task reached a terminal state in the window
- **THEN** the per-day chart says nothing was completed in this window

### Requirement: Statistics project picker

The project picker SHALL list the tenant's active projects, walking pages up to 500, and SHALL say when it does
not list every project.

#### Scenario: Too many projects

- **WHEN** the walk stops with a cursor left
- **THEN** the screen says the picker does not list every project and the figures are unaffected
