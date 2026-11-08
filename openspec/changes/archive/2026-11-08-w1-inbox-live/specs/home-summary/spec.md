## ADDED Requirements

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
