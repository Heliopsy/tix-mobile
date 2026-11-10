# desktop-integration

## MODIFIED Requirements

### Requirement: Tray icon and menu

On Linux, Windows and macOS, where the desktop shows tray icons, the app SHALL show an icon in the tray (the menu bar on macOS) whose menu offers Open tix, Quick add, Inbox with the active context's unread count, Watch while signed in, the active context's name as a disabled entry while signed in, and Quit.

#### Scenario: Menu on KDE

- **WHEN** tix runs on KDE Plasma signed in to context "Work · Acme" with 3 unread inbox items
- **THEN** the tray menu reads Open tix, Quick add, Inbox (3 unread), Watch, Work · Acme and Quit tix

#### Scenario: Signed out

- **WHEN** no context is active
- **THEN** the menu shows no context entry and no Watch entry, and Inbox carries no count

### Requirement: Tray entries open what the Android tiles open

Quick add SHALL show the window and open the `tix://quick-add` link, Inbox SHALL show the window and open `tix://inbox`, and Watch SHALL show the window and open `tix://watch`, through the same link handling as Android's tiles. Open tix SHALL show and focus the window, and Quit SHALL end the app.

#### Scenario: Quick add from the tray

- **WHEN** the window is hidden and the person picks Quick add in the tray menu
- **THEN** the window shows with the quick-add sheet open

#### Scenario: Watch from the tray

- **WHEN** the window is hidden and the person picks Watch in the tray menu
- **THEN** the window shows on the Watch screen

#### Scenario: Quit

- **WHEN** the person picks Quit tix
- **THEN** the tray icon goes away and the app ends
