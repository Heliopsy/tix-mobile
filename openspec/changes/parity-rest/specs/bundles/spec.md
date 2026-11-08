# bundles

## ADDED Requirements

### Requirement: Bundles are exported and imported

A Manage entry SHALL export a bundle of the picked component kinds, or all, as a file, and import a picked bundle
only after a preview. An import that replaces colliding components SHALL ask first.

#### Scenario: Export

- **WHEN** a person picks workflows and exports
- **THEN** the app hands out the bundle tix wrote as a `.json` file

#### Scenario: Import

- **WHEN** a person picks a bundle file
- **THEN** the app previews what each component would do and enables Import

### Requirement: Snapshots are imported after a dry run

A Manage entry SHALL import a snapshot file only after a dry run that counts what would be created, updated,
deleted and skipped, and SHALL confirm before importing. Replace SHALL be drawn as a destructive action.

#### Scenario: Replace

- **WHEN** a person picks replace and imports
- **THEN** the app warns that missing tasks and fields are deleted before sending
