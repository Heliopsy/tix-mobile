# share-intake Specification

## Purpose
Text and links shared into the app from elsewhere, which become a quick-add draft.

## Requirements

### Requirement: Shared text becomes a draft

On Android, text or a link shared to the app SHALL open quick add with it as the line, joined to the shared
subject when there is one, without adding anything until the person confirms.

#### Scenario: Link shared

- **WHEN** a browser shares `https://example.com/bug` with the subject `Login fails`
- **THEN** quick add opens holding `Login fails https://example.com/bug`

#### Scenario: Signed out

- **WHEN** text is shared while no context is active
- **THEN** the text waits and quick add opens once a context is active

### Requirement: Clipboard on a desktop

Ctrl+Shift+V or Cmd+Shift+V SHALL open quick add with the clipboard's text as the line.

#### Scenario: Paste

- **WHEN** the clipboard holds `Renew cert` and a person presses Ctrl+Shift+V
- **THEN** quick add opens holding `Renew cert`
