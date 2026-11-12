# quick-add

## ADDED Requirements

### Requirement: The hint line is tix web's

The quick-add field's hint SHALL be the line tix web shows, `Fix login !high #auth @raj due:fri +web ^web-3`, with only the words "Fix login" translated and every syntax token kept.

#### Scenario: English

- **WHEN** a person opens quick add with the app in English
- **THEN** the empty field reads `Fix login !high #auth @raj due:fri +web ^web-3`

#### Scenario: German

- **WHEN** the app is in German
- **THEN** the empty field reads `Login reparieren !high #auth @raj due:fri +web ^web-3`
