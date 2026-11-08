# app-settings Specification

## Purpose
Per-device appearance and language choices: theme mode, language and colour scheme.

## Requirements

### Requirement: Theme mode is chosen

Settings SHALL offer system, light, dark and OLED black themes, apply the choice at once and remember it across
launches on this device. The default SHALL be system.

#### Scenario: Dark chosen

- **WHEN** a person picks dark and restarts the app
- **THEN** the app is dark

#### Scenario: OLED black chosen

- **WHEN** a person picks OLED black
- **THEN** the app is dark on a pure black page at once, and still is after a restart

### Requirement: Language is chosen

The app SHALL be translated into English, Bulgarian, French and German. Settings SHALL offer the system language
and each of those, each named as its own readers write it, and SHALL remember the choice.

#### Scenario: Bulgarian chosen

- **WHEN** a person picks Български
- **THEN** the app's own text is Bulgarian at once

#### Scenario: German chosen

- **WHEN** a person picks Deutsch
- **THEN** the app's own text is German at once

### Requirement: The system theme can go black

Under the system theme, Settings SHALL offer a switch that draws the system's dark as OLED black. The switch
SHALL be remembered on this device and SHALL NOT be shown for the other themes.

#### Scenario: System dark goes black

- **WHEN** the theme is system, the switch is on and the platform turns dark
- **THEN** the app is dark on a pure black page

### Requirement: Unknown languages fall back to English

When none of the platform's preferred languages is one the app speaks, the app SHALL show English.

#### Scenario: Japanese system

- **WHEN** the system language is Japanese and the app follows the system
- **THEN** the app's text is English

### Requirement: Every language has every string

Every translation SHALL carry every key of the English template with the same placeholders, the same select
cases and at least the English plural's explicit and `other` cases. A test SHALL fail otherwise.

#### Scenario: A key added in English only

- **WHEN** a change adds a key to `app_en.arb` and not to `app_fr.arb`
- **THEN** the test suite fails naming the key
