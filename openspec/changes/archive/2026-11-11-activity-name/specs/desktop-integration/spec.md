# desktop-integration

## REMOVED Requirements

### Requirement: Tray entries open what the Android tiles open

**Reason**: Its scenario named Watch, which is now Activity, as on the web.

**Migration**: Replaced by "Tray entries open the links the Android tiles open".

## ADDED Requirements

### Requirement: Tray entries open the links the Android tiles open

Quick add SHALL show the window and open the `tix://quick-add` link, Inbox SHALL show the window and open `tix://inbox`, and Activity SHALL show the window and open `tix://activity`, through the same link handling as Android's tiles. Open tix SHALL show and focus the window, and Quit SHALL end the app.

#### Scenario: Quick add from the tray

- **WHEN** the window is hidden and the person picks Quick add in the tray menu
- **THEN** the window shows with the quick-add sheet open

#### Scenario: Activity from the tray

- **WHEN** the window is hidden and the person picks Activity in the tray menu
- **THEN** the window shows on the Activity screen

#### Scenario: Quit

- **WHEN** the person picks Quit tix
- **THEN** the tray icon goes away and the app ends

## MODIFIED Requirements

### Requirement: Tray icon and menu

On Linux, Windows and macOS, where the desktop shows tray icons, the app SHALL show an icon in the tray (the menu bar on macOS) whose menu offers Open tix, Quick add, Inbox with the active context's unread count, Activity while signed in, the active context's name as a disabled entry while signed in, and Quit.

#### Scenario: Menu on KDE

- **WHEN** tix runs on KDE Plasma signed in to context "Work · Acme" with 3 unread inbox items
- **THEN** the tray menu reads Open tix, Quick add, Inbox (3 unread), Activity, Work · Acme and Quit tix

#### Scenario: Signed out

- **WHEN** no context is active
- **THEN** the menu shows no context entry and no Activity entry, and Inbox carries no count
