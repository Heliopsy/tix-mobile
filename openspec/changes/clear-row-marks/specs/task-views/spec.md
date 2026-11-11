## ADDED Requirements

### Requirement: The keyboard cursor belongs to the keyboard

The cursor on a list, board or lanes SHALL show only after a key moves it. A pointer press on the list SHALL hide
it, and opening a task with a tap or a click SHALL NOT place it, so no row or card stays marked after pointer use.

#### Scenario: Opened with a tap

- **WHEN** a person taps a task open and comes back to the list
- **THEN** no row or card is marked

#### Scenario: Keyboard then mouse

- **WHEN** a person presses `j`, then clicks another task
- **THEN** the cursor is gone, and the next `j` starts again from the first task

## MODIFIED Requirements

### Requirement: Ticking a row shows it

Turning a row done SHALL fill its circle with a small bounce and draw the check, strike the title through from
the start of the line and mute it, and wash the row green and back, with a light haptic on touch. Turning it
open SHALL play the same backwards. A row drawn already done SHALL not animate. With reduced motion the change
SHALL be instant.

#### Scenario: Ticking

- **WHEN** a person ticks an open row
- **THEN** the strike-through sweeps across the title and settles as a struck-through title with a filled tick

#### Scenario: Reduced motion

- **WHEN** a person who asked for reduced motion ticks a row
- **THEN** the filled tick and the struck-through title show in the next frame, with no sweep

#### Scenario: Done status learned late

- **WHEN** a row in a custom done status is drawn before the workflows load, and they then load
- **THEN** it shows struck through at once, with no wash
