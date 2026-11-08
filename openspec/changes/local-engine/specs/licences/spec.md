## ADDED Requirements

### Requirement: The Licenses page lists what ships

The Licenses page SHALL list the licences of the runtime Dart packages (the closure of `dependencies`, derived from the package graph), the Flutter engine components compiled into the app, tix, and every Go module the bundled engine links for this platform. It SHALL NOT list packages only development uses.

#### Scenario: Dev tools are absent

- **WHEN** a person opens the Licenses page
- **THEN** `dio` and `github.com/heliopsy/tix` are listed and `build_runner` is not

#### Scenario: No engine, no Go modules

- **WHEN** the build has no engine
- **THEN** no Go module is listed

### Requirement: Licences that ask for no notice are left out

The Licenses page SHALL leave out licences that ask for no notice in a binary: public domain dedications, CC0-1.0, the Unlicense and 0BSD, recognised by SPDX identifier where one is known and by text otherwise. A licence that is not recognised SHALL be listed.

#### Scenario: 0BSD text

- **WHEN** a block's licence is the 0BSD text
- **THEN** it is not listed, while an ISC text is
