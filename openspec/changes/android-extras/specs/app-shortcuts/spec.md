# app-shortcuts

## ADDED Requirements

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
