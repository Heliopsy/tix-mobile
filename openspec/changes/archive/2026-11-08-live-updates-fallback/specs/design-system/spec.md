## ADDED Requirements

### Requirement: A live indicator component

The design system SHALL provide `LiveIndicator`, a dot and a short label for each live state, with a tooltip and a semantics label, in the gallery and covered by a golden.

#### Scenario: Degraded state

- **WHEN** the indicator is drawn for Polling
- **THEN** it shows a warning dot, the word Polling, and explains it in a tooltip
