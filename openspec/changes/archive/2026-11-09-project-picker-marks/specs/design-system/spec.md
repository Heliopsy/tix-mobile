# design-system

## ADDED Requirements

### Requirement: A project choice shows the project's mark

Wherever a person picks a project, the open list SHALL draw each project with its mark (icon or monogram on its
colour), its name and key, and an archived badge when archived, as the project list does. The current project
SHALL carry a check, and a picker's closed state SHALL show the chosen project's mark.

#### Scenario: Switching project

- **WHEN** a person opens the project switcher on a project's tasks
- **THEN** every project is listed with its icon in its colour, and the current project is checked

#### Scenario: A project with no icon or colour

- **WHEN** a project has neither an icon nor a colour
- **THEN** it is listed with its monogram on a muted tint, as in the project list

#### Scenario: Read aloud

- **WHEN** a screen reader reaches a project in a picker
- **THEN** it reads the project's name, and the mark is not read
