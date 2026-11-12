# audit-log

## ADDED Requirements

### Requirement: Activity is the audit feed

The app SHALL offer the tenant's audit log as Activity, a destination of its own at `/activity` with a history icon, as tix web names it. Manage SHALL NOT list the audit log, and the old `/manage/audit` location and the `tix://activity` link SHALL open Activity.

#### Scenario: Activity in the navigation

- **WHEN** a person taps Activity in the rail, or under More on a phone
- **THEN** the audit log opens, titled Activity, and its destination is marked as selected

#### Scenario: Old link

- **WHEN** something opens `/manage/audit`
- **THEN** the app shows Activity at `/activity`

#### Scenario: Not under Manage

- **WHEN** an admin opens Manage
- **THEN** Manage lists Live events and no audit log entry
