# app-settings Specification

## Purpose
Per-device appearance and language choices: theme mode, language and colour scheme.

## Requirements

### Requirement: Theme mode is chosen

Settings SHALL offer system, light and dark theme modes, apply the choice at once and remember it across
launches. The default SHALL be system.

#### Scenario: Dark chosen

- **WHEN** a person picks dark and restarts the app
- **THEN** the app is dark

### Requirement: Language is chosen

The app SHALL be translated into English and Bulgarian. Settings SHALL offer the system language, English
and Bulgarian, each language named as its own readers write it, and SHALL remember the choice.

#### Scenario: Bulgarian chosen

- **WHEN** a person picks Български
- **THEN** the app's own text is Bulgarian at once

### Requirement: Colours follow the platform

The app SHALL use Material 3 and take its colour scheme from the platform's dynamic colour where the
platform offers one, falling back to a scheme seeded from the tix accent.

#### Scenario: No dynamic colour

- **WHEN** the platform offers no dynamic colour
- **THEN** the scheme is seeded from the tix accent
