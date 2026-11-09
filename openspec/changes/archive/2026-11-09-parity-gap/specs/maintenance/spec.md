# maintenance

## MODIFIED Requirements

### Requirement: The trash restores

The trash screen SHALL list trashed tasks a keyset page at a time with when each was deleted, and SHALL restore a task with one action. It SHALL say that a trashed task is deleted for good by Delete for good or by the housekeeping trash rule.

#### Scenario: Restore

- **WHEN** a person restores a trashed task
- **THEN** it leaves the list and is back in its project

## ADDED Requirements

### Requirement: A trashed task is deleted for good after a confirmation

For a credential holding `task:delete`, each trashed task SHALL offer Delete for good, a red action that confirms first and then sends `task.purge`. Afterwards the trash list SHALL be read again. A refusal SHALL be shown with the server's message and the task SHALL stay listed.

#### Scenario: Confirmed

- **WHEN** a person confirms Delete for good on a trashed task
- **THEN** the app sends `DELETE /tasks/{ref}/trash`, the task leaves the list and the list is read again

#### Scenario: Cancelled

- **WHEN** a person cancels the confirmation
- **THEN** no request is sent and the task stays

#### Scenario: Without the scope

- **WHEN** the credential lacks `task:delete`
- **THEN** no Delete for good action is shown
