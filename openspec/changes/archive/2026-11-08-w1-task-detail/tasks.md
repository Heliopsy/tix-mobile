# Tasks

## 1. Data

- [x] 1.1 Task gains the fields the detail view reads; models for comments, dependencies, artifacts, fields, workflows, audit entries, route results, tags and the trash
- [x] 1.2 `TaskDetailRepository` and its API implementation, `TaskPatch` with apply and inverse
- [x] 1.3 Fake tix answers every new operation

## 2. Application

- [x] 2.1 `TaskDetailController`: optimistic patches, serial sends, checklist, moves, star, snooze, copy, delete and restore
- [x] 2.2 Providers for comments, dependencies, subtasks, artifacts, history, fields, workflow, actors, tags and trash
- [x] 2.3 Workflow routes, checklist parsing and snooze presets

## 3. Presentation

- [x] 3.1 `TixMarkdown` and `TixPropertyRow` components with gallery entries and goldens
- [x] 3.2 Task header, properties and their editors
- [x] 3.3 Description with checklist, subtasks, dependencies
- [x] 3.4 Comments, history and artifacts
- [x] 3.5 Task menu: star, snooze, copy, delete; shortcuts and haptics; wide layout
- [x] 3.6 English and Bulgarian strings

## 4. Checks

- [x] 4.1 Repository, controller and widget tests at compact and expanded widths
- [x] 4.2 Real server check and screenshots at 400 and 1280
