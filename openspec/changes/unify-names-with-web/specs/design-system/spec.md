# design-system

## ADDED Requirements

### Requirement: A Low contrast scheme

The design system SHALL provide a Low contrast scheme carrying tix web's `dim` palette colour for colour. It SHALL keep its own muted accent unless the tenant picked one, which it SHALL take as the dark scheme does. Status, priority and project colours SHALL come from the same palette.

#### Scenario: No tenant accent

- **WHEN** the app draws Low contrast for a tenant with no theme
- **THEN** the accent is `#5eb3ab`, as on the web

#### Scenario: A tenant accent

- **WHEN** the tenant's theme is ember
- **THEN** Low contrast takes ember's dark accent
