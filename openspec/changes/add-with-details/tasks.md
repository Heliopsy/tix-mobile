# Tasks

## 1. Spec

- [x] 1.1 `quick-add` and `command-palette` deltas

## 2. Data and application

- [x] 2.1 `TasksRepository.create` sends a structured request through the outbox; quick add uses it
- [x] 2.2 `TaskDetails` builds the request; `QuickAdder.addDetailed` creates and remembers it
- [x] 2.3 `QuickAddDraft.detailed` asks the host for the full form

## 3. Presentation

- [x] 3.1 The Add with details sheet with the web form's fields, More options and field-level refusals
- [x] 3.2 More details in quick add, carrying the line and project
- [x] 3.3 "Add with details" in the command palette

## 4. Strings and docs

- [x] 4.1 Strings in English, Bulgarian, German and French
- [x] 4.2 README feature list and `docs/architecture.md`

## 5. Tests

- [x] 5.1 Request building: empty fields left out, lists split, due date in UTC, no parse
- [x] 5.2 Form: every field sent, priority, missing title, field and general refusals, offline draft
- [x] 5.3 Host: More details carries the line and project; the palette opens the form
