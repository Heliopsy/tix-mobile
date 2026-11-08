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
