## ADDED Requirements

### Requirement: My work can include the tasks the reader holds

My work SHALL offer "Include tasks I hold". On, it SHALL also list the tasks the reader holds a claim on under the
same filter, after the assigned ones, each task once.

#### Scenario: A claimed task assigned to someone else

- **WHEN** the reader holds a claim on a task assigned to nobody and turns on Include tasks I hold
- **THEN** the task is listed in My work under its deadline heading

#### Scenario: Off

- **WHEN** Include tasks I hold is off
- **THEN** My work asks only for the tasks assigned to the reader

### Requirement: My work's destination counts overdue tasks

The My work navigation destination SHALL show how many of the reader's open assigned tasks are past their deadline,
in the danger colour, as "99+" past 99, and SHALL show nothing while none are.

#### Scenario: Two overdue

- **WHEN** two of the reader's open tasks were due yesterday
- **THEN** My work's icon carries a red 2
