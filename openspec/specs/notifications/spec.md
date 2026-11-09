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

### Requirement: Notifications offer actions

On Android, a notification for a new inbox item about a task SHALL offer Done, Snooze and an inline Reply. Done SHALL move the task to its workflow's done state, Snooze SHALL snooze it until 09:00 tomorrow on the device's clock, and Reply SHALL post the typed text as a comment.

#### Scenario: Replying from the shade

- **WHEN** a person types "on it" into Reply on a notification about `infra-4`
- **THEN** a comment "on it" is added to `infra-4` without the app opening

#### Scenario: Not about a task

- **WHEN** the item opens no task
- **THEN** the notification offers no actions

### Requirement: Actions run without the app

A notification action SHALL run in the background, in the app's engine when it is up and otherwise in a headless one, and SHALL not open the app. Afterwards the notification SHALL be dismissed, and an item the server took the action for SHALL be marked read.

#### Scenario: App closed

- **WHEN** a person taps Done while tix is not running
- **THEN** the task is completed, the notification goes away and no tix screen opens

### Requirement: A failed action says so

When the server refuses an action, its context is no longer saved, or Done cannot find the workflow's done state, the app SHALL dismiss the notification and show one short follow-up naming the action and no task. Tapping it SHALL open the item.

#### Scenario: Refused reply

- **WHEN** the server answers a reply with 403
- **THEN** a notification says the reply could not be sent and to open tix

### Requirement: Hidden content limits actions

When task content is hidden for the context, the notification SHALL offer no Reply, and on Android 12 and later Done and Snooze SHALL require the device to be unlocked. The public version shown on a locked screen SHALL carry no actions.

#### Scenario: Hidden content on a locked phone

- **WHEN** content is hidden and a person taps Done on the notification of a locked Android 14 phone
- **THEN** the phone asks for an unlock before the task is completed, and no Reply is offered
