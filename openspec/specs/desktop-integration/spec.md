# desktop-integration Specification

## Purpose
On Linux, Windows and macOS the app lives in the tray or menu bar as well as its window: the tray menu reaches quick add and the inbox through the same links as Android's tiles, closing the window can keep tix running, it can start at login, a global hotkey opens quick add, and only one copy runs at a time.

## Requirements

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

### Requirement: Clicking the icon toggles the window

Where the platform reports clicks on the icon (Windows, macOS), a click SHALL hide a visible window and show a hidden one, and a secondary click SHALL open the menu. On Linux, where tray hosts open the menu on a click, the menu SHALL be the way in.

#### Scenario: Windows

- **WHEN** the window is visible and the person clicks the tray icon
- **THEN** the window hides, and the next click shows it again

### Requirement: Unread count in the tooltip and Dock

The icon's tooltip SHALL carry the active context's unread inbox count on Windows and macOS, and macOS SHALL show it as the Dock badge, 99+ above 99. With nothing unread the tooltip SHALL read tix and the badge SHALL be cleared.

#### Scenario: Seven unread on a Mac

- **WHEN** the active context has 7 unread items
- **THEN** the Dock badge shows 7 and the menu bar icon's tooltip reads "tix: 7 unread"

### Requirement: Close to tray

When close to tray is on, closing the window SHALL hide it and keep the app running, with live updates, sync and notifications. When it is off, closing the window SHALL end the app. A tapped notification SHALL show a hidden window.

#### Scenario: Closing with close to tray on

- **WHEN** the person closes the window
- **THEN** the window hides, the tray icon stays and a new inbox item still raises a notification

### Requirement: Close to tray follows the tray

Close to tray SHALL default to on where a tray shows and SHALL be off where none does. Without a tray the setting SHALL be shown switched off and disabled with the reason, so the window can never be hidden with no way back.

#### Scenario: GNOME without the extension

- **WHEN** tix runs on GNOME with no StatusNotifierWatcher on the session bus
- **THEN** no tray icon is created, closing the window quits, and Settings says this desktop shows no tray icons

### Requirement: Start at login

The app SHALL offer start at login as a setting, off until turned on, where the platform allows: Linux (an autostart entry, or the Background portal under Flatpak), Windows and macOS 13 and later. A refusal SHALL leave the switch as it was and say so.

#### Scenario: Turning it on in Flatpak

- **WHEN** the person turns on start at login in the Flatpak build
- **THEN** the Background portal is asked to start tix at login and the switch turns on once it agrees

### Requirement: A login launch starts hidden

A launch from the login item SHALL keep the window hidden when a tray shows and close to tray is on, and SHALL show it otherwise.

#### Scenario: Login on Windows

- **WHEN** Windows starts tix at sign-in and close to tray is on
- **THEN** only the tray icon appears

### Requirement: Global quick-add hotkey

Where the desktop has global hotkeys (Windows, macOS, Linux under X11) the app SHALL offer, off until turned on, a hotkey (Ctrl+Shift+Space, ⌃⇧Space on macOS) that shows the window with quick add open from any app. A key another app holds SHALL leave the setting off and say so.

#### Scenario: Hotkey from another app

- **WHEN** the hotkey is on and the person presses Ctrl+Shift+Space while a browser has focus
- **THEN** tix comes to the front with the quick-add sheet open

### Requirement: No hotkey setting without global hotkeys

Where the desktop offers no global hotkeys, as on a Wayland session, the hotkey setting SHALL NOT be shown.

#### Scenario: Wayland

- **WHEN** tix runs on a Wayland session
- **THEN** Settings shows no quick-add hotkey switch

### Requirement: One instance

A second launch of the app on a desktop SHALL bring the running window forward, shown if it was hidden, and SHALL NOT start another copy. A `tix://` link it was given SHALL be followed by the running app.

#### Scenario: Launching again from the menu

- **WHEN** tix is hidden in the tray and the person starts it again from the application menu
- **THEN** the hidden window shows and no second tix process remains

#### Scenario: A link on Linux

- **WHEN** a `tix://inbox` link is opened on Linux while tix runs
- **THEN** the running window comes forward on the inbox

### Requirement: Desktop only

The tray, close to tray, start at login and the hotkey SHALL NOT exist on Android and iOS, which SHALL carry no native code for them, and the Settings section SHALL only be shown on a desktop.

#### Scenario: Android Settings

- **WHEN** Settings opens on Android
- **THEN** there is no Desktop section

### Requirement: The Linux tarball carries the tray libraries

The Linux release tarball SHALL contain libayatana-appindicator3 0.6 or later, built from upstream's release, and the libayatana-indicator3, libayatana-ido3 and libdbusmenu libraries the tray plugin loads, and SHALL load them from its own `lib/` directory, so it starts on a distro that lacks them and has the tooltip API whatever version the distro ships. It SHALL NOT bundle glib, GTK or libc.

#### Scenario: Fedora without the appindicator package

- **WHEN** the x64 tarball is unpacked on Fedora 43 KDE, which has no libayatana-appindicator3 installed, and `tix_mobile` is started
- **THEN** the window opens and the tray icon shows

#### Scenario: A build that would load the system copy

- **WHEN** a CI or release build produces a Linux bundle in which `ldd` resolves any ayatana or dbusmenu library outside the bundle's `lib/`
- **THEN** the job fails

#### Scenario: A bundle without the tooltip API

- **WHEN** a CI or release build produces a Linux bundle whose libayatana-appindicator3 does not export `app_indicator_set_tooltip_title` and `app_indicator_set_tooltip_body`
- **THEN** the job fails
