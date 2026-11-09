# live-updates

## ADDED Requirements

### Requirement: The live mode follows the context's name

On a phone the indicator SHALL start where the context's name ends, on the same line, never in the middle of the
bar, and SHALL take at most half its width. On the rail it SHALL be a dot at the avatar's end corner. Both SHALL
follow the writing direction.

#### Scenario: A short name

- **WHEN** the context's name is short on a 400 pixel wide phone
- **THEN** the indicator starts just after the name, in the bar's first half

#### Scenario: Right to left

- **WHEN** the text runs right to left
- **THEN** the indicator sits just before the name, to its left
