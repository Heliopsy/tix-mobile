# release-channels

## ADDED Requirements

### Requirement: App Store update carries What's New

Before submitting a version for review while another is live, the promote workflow SHALL set What's New on every
locale of that version that has none, from the CHANGELOG.md entries since the live version, keeping only features,
fixes, performance and reverts, as lines without scopes, hashes or links, at most 4000 characters.

#### Scenario: Update after a live version

- **WHEN** 0.20.0 is live and the workflow submits 0.21.0, whose en-US What's New is empty
- **THEN** en-US gets the user-facing changes of 0.20.1 and 0.21.0 before the version is submitted

### Requirement: Existing What's New is kept

The promote workflow SHALL NOT change a locale's What's New that is already set, and SHALL NOT set What's New on
the app's first version. A dry run SHALL print the text and the locales it would set, and change nothing.

#### Scenario: Text typed in App Store Connect

- **WHEN** the version's en-US What's New was written in App Store Connect
- **THEN** the workflow submits it with that text unchanged

#### Scenario: Dry run

- **WHEN** a dry run reaches a version with a processed build
- **THEN** its summary shows the What's New text and the locales that would get it
