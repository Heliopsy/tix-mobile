# self-update

## MODIFIED Requirements

### Requirement: Off where something else updates the app

Updates SHALL be off, with no check and no Updates section, in a Flatpak, in a Snap, on iOS outside an App Store install, in the F-Droid build, in any other build made with `TIX_SELF_UPDATE=false`, and when a store or any installer other than the system package installer installed the GitHub APK. On Android installed from the GitHub APK the app SHALL only show a notice with a link and SHALL never download or install an APK.

#### Scenario: Flathub

- **WHEN** the app runs inside Flatpak
- **THEN** it never contacts GitHub and Settings has no Updates section

#### Scenario: Play install

- **WHEN** Google Play installed the app
- **THEN** GitHub is never asked; Play's in-app update API is

#### Scenario: F-Droid

- **WHEN** the F-Droid build runs
- **THEN** no update check runs and no update notification shows

#### Scenario: TestFlight

- **WHEN** the iOS app was installed from TestFlight
- **THEN** no update check runs, as TestFlight tells testers about new builds itself

#### Scenario: GitHub APK

- **WHEN** the APK from the GitHub release was installed through the system package installer and a newer release exists
- **THEN** Settings shows the update with a Download link to the release page and nothing is installed

## ADDED Requirements

### Requirement: Ask Google Play in the Play build

The Google Play build SHALL use the `store` mode backed by Play's in-app update API: it SHALL offer an update only when Play reports one available, as the version its version code stands for, and SHALL check nothing on GitHub. It SHALL download nothing itself.

#### Scenario: Play has a newer version

- **WHEN** the Play build of 0.20.0 runs and Play reports an update with version code 21000
- **THEN** Settings says an update to 0.21.0 is available with Update from Google Play

#### Scenario: Play has none

- **WHEN** Play reports no update, or the build was not installed by Play
- **THEN** no update is offered

### Requirement: Update through Play

In the Play build, Update from Google Play and a tap on the update notification SHALL start Play's flexible in-app update when Play allows one, and SHALL otherwise open the app's Play listing, in the Play Store app when there is one and on the web when not.

#### Scenario: Flexible update allowed

- **WHEN** the person taps the update notification and Play allows a flexible update
- **THEN** Play's update prompt shows and the app restarts into the new version once it is downloaded

#### Scenario: Not allowed

- **WHEN** Play allows no flexible update
- **THEN** the Play listing of `red.tix.tix_mobile` opens

### Requirement: Play updates notify once per version code

The Play build SHALL notify a newer version once per version code Play reports, in the running app and from Android's background update job, worded for Google Play. A background run that carries no answer from Play SHALL fetch nothing and SHALL not count towards the three-hour limit.

#### Scenario: Same code again

- **WHEN** the background job finds version code 21000 twice, three hours apart, and later 21001
- **THEN** one notification for 0.21.0 showed and one more for 0.21.1

#### Scenario: Widget refresh

- **WHEN** the widget refresh runs the background check in the Play build
- **THEN** nothing is checked and the next update job still runs its check
