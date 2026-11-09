# notifications

## ADDED Requirements

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
