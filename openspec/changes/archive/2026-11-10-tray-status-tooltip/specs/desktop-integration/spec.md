# desktop-integration

## ADDED Requirements

### Requirement: The tray icon's hover text shows status

The tray icon's hover text SHALL say how many instances are set up, give one line per instance (the active one first, at most three, then how many more) with its live, sync and outbox state, and the active context's unread inbox count. Without an active context it SHALL say tix is not signed in.

#### Scenario: Two instances

- **WHEN** "work" on tix.example.com is active, live and last synced 2 minutes ago, "home" is a local instance, and the inbox holds 5 unread items
- **THEN** the hover text reads "tix · 2 instances connected", "work (tix.example.com): synced 2 minutes ago", "home (local)" and "5 unread in inbox"

#### Scenario: Offline with queued changes

- **WHEN** the active instance "home" cannot reach its server and 3 changes wait in the outbox
- **THEN** its line reads "home (local): offline, 3 changes queued"

### Requirement: The hover text stays current without flooding the tray

The app SHALL update the hover text when the state behind it changes, at most once every two seconds, sending the latest text when the two seconds are up, and SHALL rebuild it once a minute so relative times stay right. Updating it SHALL NOT rebuild the tray menu.

#### Scenario: A burst of changes

- **WHEN** the unread count changes three times within one second
- **THEN** the tray gets the first text at once and the last one two seconds later, and nothing in between

#### Scenario: Time passes

- **WHEN** a minute passes with no other change
- **THEN** "synced just now" becomes "synced 1 minute ago"

### Requirement: Each desktop gets the most its tray can show

On Windows and macOS the hover text SHALL be the tray icon's tooltip, one line per item, kept within Windows' 127 characters by leaving out instance lines. On Linux the first line SHALL be the AppIndicator's title, and where libayatana-appindicator supports tooltips the first line SHALL be the tooltip title and the rest its body.

#### Scenario: KDE Plasma with tooltip support

- **WHEN** tix runs on KDE Plasma with libayatana-appindicator 0.6.0 or later
- **THEN** hovering the icon shows the headline with the instance and unread lines beneath it

#### Scenario: Windows with many instances

- **WHEN** the full text would pass 127 characters
- **THEN** the tooltip leaves out instance lines from the end, keeping the headline and the unread line
