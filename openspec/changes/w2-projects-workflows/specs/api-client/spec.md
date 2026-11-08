# api-client

## ADDED Requirements

### Requirement: A null that clears is sent

For an input field whose null means "clear", the generated client SHALL distinguish leaving it out from clearing
it, and send JSON null for a clear. No request SHALL be built by hand to carry one.

#### Scenario: Clear a due date

- **WHEN** a person clears a task's due date
- **THEN** the generated `task.update` sends `"due_at": null`
