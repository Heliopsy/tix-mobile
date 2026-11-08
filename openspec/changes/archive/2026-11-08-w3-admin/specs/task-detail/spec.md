# task-detail

## ADDED Requirements

### Requirement: A claim can be force-released

When a task is claimed, the task menu SHALL offer a red "Force-release claim" that asks for an optional reason and
sends `POST /api/v1/tasks/{ref}/claim/reclaim`. An unclaimed task SHALL NOT offer it, and a refusal SHALL keep the
form open with the server's message.

#### Scenario: Release with a reason

- **WHEN** an admin releases the claim on a claimed task with the reason "worker died"
- **THEN** the app sends the reason, the task shows unclaimed and a toast says so
