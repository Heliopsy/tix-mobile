# notifications Specification

## Purpose
Local notifications for new inbox items while the app runs, and the choices that govern them on this device.

## Requirements

### Requirement: New inbox items notify

While the app runs or was recently backgrounded, a new unread inbox item of a kind the person enabled SHALL
show a local notification naming who did what to which task, when notifications are on for the active context.
An item SHALL notify once, and items present when the app started SHALL NOT notify.

#### Scenario: Assigned while the app is in the background

- **WHEN** somebody assigns the person a task and the app is backgrounded
- **THEN** a notification says so

#### Scenario: Starting the app

- **WHEN** the app starts with unread items already in the inbox
- **THEN** no notification is shown for them

### Requirement: Tapping a notification opens the task

Tapping a notification SHALL open the item's task and mark the item read.

#### Scenario: Tapping

- **WHEN** a person taps a notification for `infra-4`
- **THEN** the app opens `infra-4`

### Requirement: Notifications are chosen in settings

Settings SHALL offer notifications on or off for the active context, off until turned on, and a switch per kind.
Turning them on SHALL ask the platform's permission (Android 13 and later, iOS, macOS); when refused, they stay
off and the screen says how to allow them.

#### Scenario: Permission refused

- **WHEN** a person turns notifications on and refuses the permission
- **THEN** the switch stays off and the screen says notifications are blocked

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
