# app-branding Specification

## Purpose
How the app looks like tix: its icons, launch screens, name and the mark on its own screens.

## Requirements

### Requirement: The app wears the tix mark

Every platform's launcher icon, window icon and launch screen SHALL show the tix mark, rendered from the
same SVG the tix web app uses as its favicon, and the app's user-visible name SHALL be `tix`.

#### Scenario: Installed on a phone

- **WHEN** a person installs the app on Android or iOS
- **THEN** the launcher shows the tix mark labelled `tix`

#### Scenario: Launched in dark mode

- **WHEN** the app starts while the device is in dark mode
- **THEN** the launch screen shows the mark on tix's dark page background

### Requirement: The app's own screens carry the mark

The connect screen SHALL show the tix mark above its form, and Settings SHALL offer an About entry whose
dialog shows the mark beside the app's name.

#### Scenario: About opened

- **WHEN** a person opens About in Settings
- **THEN** a dialog shows the tix mark and the name `tix`
