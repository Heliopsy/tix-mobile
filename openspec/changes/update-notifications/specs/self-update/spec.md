# self-update

## MODIFIED Requirements

### Requirement: Check GitHub releases for a newer version

Where updates are not off, the app SHALL ask for the latest release at start and about every three hours while "Check for updates" is on, and whenever the person picks Check now: GitHub's latest release of heliopsy/tix-mobile, or in the `store` mode the App Store's version. It SHALL skip drafts and prereleases and SHALL offer a release only when its version is newer than the running one by semantic version precedence.

#### Scenario: Newer release

- **WHEN** version 0.11.0 runs and the latest release is v0.12.0
- **THEN** Settings and About say an update to 0.12.0 is available, with a What's new link to its release notes

#### Scenario: Same version

- **WHEN** version 0.12.0 runs and the latest release is v0.12.0
- **THEN** Settings says tix is up to date and nothing is downloaded

#### Scenario: Checking turned off

- **WHEN** "Check for updates" is off
- **THEN** nothing is fetched until the person picks Check now

#### Scenario: Every three hours

- **WHEN** the app keeps running with "Check for updates" on
- **THEN** it checks again three hours after the last check, give or take twenty minutes

### Requirement: Off where something else updates the app

Updates SHALL be off, with no check and no Updates section, in a Flatpak, in a Snap, on iOS outside an App Store install, in any other build made with `TIX_SELF_UPDATE=false`, and on Android when a store or any installer other than the system package installer installed the app. On Android installed from the GitHub APK the app SHALL only show a notice with a link and SHALL never download or install an APK.

#### Scenario: Flathub

- **WHEN** the app runs inside Flatpak
- **THEN** it never contacts GitHub and Settings has no Updates section

#### Scenario: Play install

- **WHEN** Google Play installed the app
- **THEN** no update check runs and no update notification shows

#### Scenario: TestFlight

- **WHEN** the iOS app was installed from TestFlight
- **THEN** no update check runs, as TestFlight tells testers about new builds itself

#### Scenario: GitHub APK

- **WHEN** the APK from the GitHub release was installed through the system package installer and a newer release exists
- **THEN** Settings shows the update with a Download link to the release page and nothing is installed

### Requirement: Update settings

Settings SHALL offer, where updates are not off, "Check for updates" (on by default, its help saying it also notifies), Check now, and, where the app can install updates itself, "Install updates automatically" (off by default). The choices SHALL be kept on the device.

#### Scenario: Defaults

- **WHEN** a Linux tarball install opens Settings for the first time
- **THEN** "Check for updates" is on and "Install updates automatically" is off

## ADDED Requirements

### Requirement: Ask the App Store in App Store builds

An iOS build installed from the App Store SHALL use the `store` mode: it SHALL ask Apple's public lookup for bundle `red.tix.tixMobile` in the device's storefront, offer the version found there when it is newer, and send the person to the app's App Store page to update. It SHALL download nothing itself.

#### Scenario: App Store has a newer version

- **WHEN** an App Store install of 0.20.0 runs and the lookup answers version 0.21.0
- **THEN** Settings says an update to 0.21.0 is available with Open the App Store, which opens the app's App Store page

#### Scenario: Not listed in the storefront

- **WHEN** the lookup answers no result
- **THEN** no update is offered

### Requirement: Notify a newer version once

When an automatic check finds a newer version, the app SHALL show a system notification titled with that version, worded for what the build does with it: download from the release page, update from the App Store, or, once staged, restart to update or install on quit. It SHALL notify each version once, remembered across restarts, SHALL not notify from Check now, and SHALL show nothing while the platform does not allow notifications.

#### Scenario: Once per version

- **WHEN** a sideloaded APK finds 0.21.0 at start, again three hours later and again after a restart
- **THEN** one notification "tix 0.21.0 is available" showed, and 0.22.0 later shows one more

#### Scenario: Notifications not allowed

- **WHEN** notifications are off for tix in the system settings
- **THEN** no update notification shows and it is not counted as shown

#### Scenario: Staged on the desktop

- **WHEN** a Linux tarball install stages 0.21.0 with "Install updates automatically" on
- **THEN** the notification says tix 0.21.0 is ready to install and installs when tix quits

### Requirement: Open the update from its notification

Tapping an update notification, or launching the app from one, SHALL open About, which shows the update panel, or, in the `store` mode, the app's App Store page.

#### Scenario: Tap on a desktop

- **WHEN** the person clicks the update notification on Windows
- **THEN** the window shows About with the update

#### Scenario: Tap in an App Store build

- **WHEN** the person taps the update notification on an iPhone with an App Store install
- **THEN** the App Store opens on tix's page

### Requirement: Look for updates while the app is closed

On Android and iOS, the background runs the app already has (iOS background refresh, Android's widget refresh) and an Android job every three hours SHALL run the same check while the app is closed, at most once every three hours by the stored time of the last check, and notify as the running app does. The OS decides when they run; this is best effort.

#### Scenario: Rate limit

- **WHEN** iOS runs a background refresh one hour after the last check
- **THEN** nothing is fetched

#### Scenario: Checking off

- **WHEN** "Check for updates" is off
- **THEN** the background runs fetch nothing and Android's update job is cancelled
