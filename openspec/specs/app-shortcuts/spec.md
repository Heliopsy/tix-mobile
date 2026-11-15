# app-shortcuts Specification

## Purpose
Launcher shortcuts on Android and home-screen quick actions on iOS: the few things worth one press from the home screen.

## Requirements

### Requirement: Launcher shortcuts

On Android and iOS the app SHALL offer Quick add, Inbox and My work from its launcher icon. Quick add SHALL open the
sheet; Inbox and My work SHALL open their screens, or Projects while those are not routed.

#### Scenario: Quick add shortcut

- **WHEN** a person picks Quick add from the launcher icon
- **THEN** the app opens with quick add

### Requirement: Quick Settings tiles

On Android 7 and later the app SHALL offer two Quick Settings tiles named and drawn as tix's. Quick add SHALL open the quick-add sheet over the app, and Inbox SHALL open the inbox, each through a `tix://` link. On Android 14 and later the tile SHALL start the app with a PendingIntent, and earlier it SHALL start it and collapse the shade.

#### Scenario: Quick add tile

- **WHEN** a person taps the Quick add tile while another app is on screen
- **THEN** the shade closes and tix opens with the quick-add sheet

#### Scenario: Locked phone

- **WHEN** a person taps the Inbox tile on a locked phone
- **THEN** the phone asks for an unlock before tix opens the inbox

### Requirement: The Inbox tile shows the unread count

The Inbox tile SHALL show the active context's unread inbox count as its subtitle, read from the inbox widget snapshot each time the panel opens, and SHALL read no credential. With no snapshot it SHALL say to open tix.

#### Scenario: Three unread

- **WHEN** the active context's inbox snapshot holds 3 unread items and the person opens Quick Settings
- **THEN** the Inbox tile reads "3 unread" and is drawn active

#### Scenario: Before the app ran

- **WHEN** no snapshot has been written yet
- **THEN** the Inbox tile says to open tix

### Requirement: Pinned shortcuts

Where the launcher supports pinned shortcuts, a project and a saved filter SHALL offer Add to home screen. The shortcut SHALL open the project or the filter through a `tix://` link carrying the context it was made in, and pinning the same target again SHALL update the one shortcut.

#### Scenario: Pinning a project

- **WHEN** a person in context `s1.acme` adds project OPS to the home screen and later taps the shortcut
- **THEN** the link `tix://projects/OPS?context=s1.acme` switches to that context if needed and opens OPS

#### Scenario: Pinning a saved filter

- **WHEN** a person adds the saved filter with id `f7` to the home screen
- **THEN** the shortcut opens `tix://tasks?filter=f7` in the context it was made in

### Requirement: Pinning only where it works

Add to home screen SHALL NOT be shown on platforms or launchers that cannot pin shortcuts.

#### Scenario: Linux

- **WHEN** a project is open on Linux
- **THEN** there is no Add to home screen

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
