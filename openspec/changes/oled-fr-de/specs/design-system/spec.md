# design-system

## ADDED Requirements

### Requirement: An OLED black scheme

The design system SHALL provide an OLED black scheme: a `#000000` page, near-black surfaces separated by
hairlines, and the dark scheme's text, status, priority and project colours. Every text token SHALL clear 4.5:1
on its page and surface. The tenant accent SHALL apply as in dark.

#### Scenario: Status keeps its colour

- **WHEN** a task in progress is drawn in OLED black under a plum tenant
- **THEN** its status is the same teal as in dark and the page is black

### Requirement: Pick-one settings wrap

A pick-one setting SHALL show every option at once, wrapping onto more lines rather than scrolling an option out
of sight, at any width the app supports and at twice the text size.

#### Scenario: Five languages on a phone

- **WHEN** Settings is open 400 wide at 200% text in German
- **THEN** every language is visible and nothing overflows

### Requirement: Long languages fit

The shared components and the Settings and About screens SHALL draw without overflow at twice the text size in
English, German and French, at compact and expanded widths.

#### Scenario: German due mark

- **WHEN** an overdue task row is drawn 1280 wide at 200% text in German
- **THEN** nothing overflows
