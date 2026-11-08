# notifications

## ADDED Requirements

### Requirement: Task content can be hidden from notifications

Notification settings SHALL offer, per context, a switch that hides task content, off by default and usable only
while notifications are on. When on, every notification of that context SHALL read "New in your inbox" and name no
task, comment or person; a tap SHALL still open the item.

#### Scenario: Hidden

- **WHEN** content is hidden and a mention arrives
- **THEN** the notification says only "New in your inbox" and opens the task when tapped

#### Scenario: Other contexts

- **WHEN** content is hidden in one context
- **THEN** another context's notifications still name the task

### Requirement: Locked screens see a public version

Every notification SHALL carry a public version naming no task. On Android it SHALL be posted as private with that
public version, so a locked screen shows the generic text.

#### Scenario: Locked phone

- **WHEN** a notification arrives on a locked Android phone
- **THEN** the lock screen shows "New in your inbox", not the task title
