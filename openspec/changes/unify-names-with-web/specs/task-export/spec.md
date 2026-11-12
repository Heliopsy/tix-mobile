# task-export

## ADDED Requirements

### Requirement: A project opens Import and export on itself

A project's screen SHALL offer Import and export among its header actions, as tix web's project header offers Export, when the credential may export or import. It SHALL open the transfer screen at `/projects/<KEY>/transfer` with that project picked, and going back SHALL return to the project.

#### Scenario: From the project

- **WHEN** a member opens project `infra` and taps Import and export
- **THEN** the transfer screen opens with `infra` picked for export and import

#### Scenario: No export or import scope

- **WHEN** the credential holds neither `export` nor `import`
- **THEN** the project's header offers no Import and export
