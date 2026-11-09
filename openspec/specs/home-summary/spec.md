# home-summary Specification

## Purpose
The numbers at the top of the inbox: the tenant's open work by state and the caller's overdue and due-today tasks.

## Requirements

### Requirement: A summary heads the inbox

The inbox SHALL open with a summary of the tenant from `GET /api/v1/stats`: tasks in each state category and
tasks completed in the last seven days, and the caller's open tasks overdue and due today, read from
`GET /api/v1/tasks` with `assignee=me` and `due_before`. A summary that fails SHALL NOT hide the inbox.

#### Scenario: Overdue work

- **WHEN** the person has two open tasks past due
- **THEN** the summary shows 2 overdue

#### Scenario: Stats refused

- **WHEN** reading the stats fails
- **THEN** the inbox still lists its items

### Requirement: Summary tiles keep their size

A summary tile's size SHALL NOT depend on its count. Tiles in a row SHALL share their width and height, and four
SHALL share a row only while each keeps room at the current text scale, else two. Counts SHALL use tabular
figures, read in full below 1000 and in the locale's compact form from there, and SHALL never wrap.

#### Scenario: Nine to a hundred

- **WHEN** the overdue count goes from 9 to 10, then 100
- **THEN** no tile changes size or position

#### Scenario: A large count

- **WHEN** 1234 tasks are open and the language is English
- **THEN** the tile reads 1.2K and a screen reader hears 1,234

#### Scenario: Large text

- **WHEN** the text scale is 200% on a 400 pixel wide phone
- **THEN** the tiles sit two to a row and nothing overflows
