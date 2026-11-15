# app-shortcuts

## ADDED Requirements

### Requirement: iOS controls

On iOS 18 and later the app SHALL offer two controls for Control Center, the Lock Screen and the Action Button.
Quick add SHALL open the app on the quick add sheet, and Inbox SHALL open the inbox, each through the same
`tixwidget://` link a widget uses, in the active context.

#### Scenario: Quick add from Control Center

- **WHEN** a person taps the Quick add control in Control Center
- **THEN** tix opens with the quick add sheet

#### Scenario: Action Button

- **WHEN** a person has set the Action Button to tix's Inbox control and presses it
- **THEN** tix opens the inbox

#### Scenario: Older iOS

- **WHEN** the phone runs iOS 17
- **THEN** no tix control is offered and the widgets work as before

### Requirement: The Inbox control shows the unread count

The Inbox control SHALL show the active context's unread count from the inbox widget snapshot beside its name, and
SHALL read no credential. With no snapshot it SHALL show only its name. The app SHALL ask iOS to redraw the controls
when it writes widget snapshots.

#### Scenario: Five unread

- **WHEN** the active context's inbox snapshot holds 5 unread items and the person opens Control Center
- **THEN** the Inbox control reads "Inbox · 5"

#### Scenario: Before the app ran

- **WHEN** no snapshot has been written yet
- **THEN** the Inbox control reads "Inbox"

### Requirement: Siri and Spotlight shortcuts

On iOS 18 and later the app SHALL offer App Shortcuts for Add a task, Open inbox and Open my work, in English,
Bulgarian, German and French. Every Siri phrase SHALL contain the app's name. Add a task SHALL take an optional
title that the quick add sheet opens with, and SHALL NOT create a task without the sheet.

#### Scenario: Asking Siri

- **WHEN** a person says "Add a task in tix"
- **THEN** tix opens with the quick add sheet

#### Scenario: A title from Shortcuts

- **WHEN** a shortcut runs Add a task with the title "Call the bank"
- **THEN** tix opens quick add with "Call the bank" in the line, not yet sent
