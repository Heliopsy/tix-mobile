# task-views

## ADDED Requirements

### Requirement: Lanes group by project, assignee, priority, tag or due

While lanes are drawn the sort menu SHALL offer "Group lanes by" Project, Assignee, Priority, Tag or Due, kept per
screen. A project screen SHALL offer all but Project and default to Assignee; the task list SHALL default to
Project. Each grouping SHALL keep its arrangement under `lanes` for projects and `lanes:BY` otherwise.

#### Scenario: Lanes by priority

- **WHEN** a person drawing lanes picks Priority
- **THEN** a lane per priority holding a loaded task is drawn, highest first, arranged under `lanes:priority`

#### Scenario: A project screen

- **WHEN** a person opens lanes on the infra project
- **THEN** the lanes are grouped by assignee and Project is not offered

### Requirement: Lanes are built as tix builds them

People SHALL be drawn A to Z by handle, then Unassigned; priorities highest first; tags named by the filter first,
then A to Z, then No tag; deadline buckets in order and only when a card lands in them. A person, priority or tag
the filter names SHALL get a lane even when empty.

#### Scenario: A named tag with nothing in it

- **WHEN** the filter is `tag:zeta` and no loaded task carries it
- **THEN** a zeta lane is drawn first, empty

### Requirement: A card with several tags is drawn once

By tag, a card SHALL be drawn once, under the first of its tags whose lane the reader's arrangement shows.

#### Scenario: Hiding a tag lane

- **WHEN** a task tagged api and ops is drawn and the api lane is hidden
- **THEN** the task is drawn under ops

### Requirement: A lane heading narrows to the lane

A lane's name SHALL replace the filter with the lane's term (`project:KEY`, `assignee:HANDLE`, `priority:NAME` or
`tag:NAME`), keeping the lanes and their grouping. Unassigned, No tag and deadline lanes SHALL not be links.

#### Scenario: Tapping a priority heading

- **WHEN** a person taps Highest on lanes by priority
- **THEN** the filter becomes `priority:highest` and the lanes stay grouped by priority

## MODIFIED Requirements

### Requirement: One query drawn as a list, a board or lanes

The task screen SHALL draw one query as a list, a board or lanes, switched without reloading. The Tasks
screen covers every project; a project screen is scoped to its project and offers the list, the board and lanes.

#### Scenario: Switching the drawing

- **WHEN** a person filtered by `tag:ops` switches from the board to lanes
- **THEN** the lanes show the same tasks and no new listing request is made

### Requirement: Lanes draw one lane per project

Grouped by project, lanes SHALL draw one lane per project holding a loaded task, or named by a `project:` term,
each with its cards, a tick that completes or reopens and the status on the card. Finished cards SHALL show only
while Finished is on.

#### Scenario: Two projects

- **WHEN** the loaded tasks are in infra and web
- **THEN** two lanes are drawn, headed by each project in its colour
