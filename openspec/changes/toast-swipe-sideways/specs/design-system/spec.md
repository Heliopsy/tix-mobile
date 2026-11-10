# design-system

## ADDED Requirements

### Requirement: A toast is swiped away sideways or down

Every toast SHALL be dismissable by swiping it left or right. A toast shown with `showTixToast` SHALL also be dismissable by swiping it down. The theme SHALL set the sideways direction, so a toast added later gets it without opting in.

#### Scenario: Swiped sideways

- **WHEN** a person flings a toast to the left or to the right
- **THEN** the toast leaves and does not come back

#### Scenario: Swiped down

- **WHEN** a person flings a toast down
- **THEN** the toast leaves, as it did before
