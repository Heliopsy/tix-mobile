# Tasks

## 1. Data

- [ ] 1.1 Task gains the fields the detail view reads; models for comments, dependencies, artifacts, fields, workflows, audit entries, route results, tags and the trash
- [ ] 1.2 `TaskDetailRepository` and its API implementation, `TaskPatch` with apply and inverse
- [ ] 1.3 Fake tix answers every new operation

## 2. Application

- [ ] 2.1 `TaskDetailController`: optimistic patches, serial sends, checklist, moves, star, snooze, copy, delete and restore
- [ ] 2.2 Providers for comments, dependencies, subtasks, artifacts, history, fields, workflow, actors, tags and trash
- [ ] 2.3 Workflow routes, checklist parsing and snooze presets

## 3. Presentation

- [ ] 3.1 `TixMarkdown` and `TixPropertyRow` components with gallery entries and goldens
- [ ] 3.2 Task header, properties and their editors
- [ ] 3.3 Description with checklist, subtasks, dependencies
- [ ] 3.4 Comments, history and artifacts
- [ ] 3.5 Task menu: star, snooze, copy, delete; shortcuts and haptics; wide layout
- [ ] 3.6 English and Bulgarian strings

## 4. Checks

- [ ] 4.1 Repository, controller and widget tests at compact and expanded widths
- [ ] 4.2 Real server check and screenshots at 400 and 1280
