# Tasks

## 1. Spec

- [x] 1.1 `task-export` and `project-admin` deltas

## 2. Data

- [x] 2.1 `TransferRepository.importTasks` sends format, mapping, mode and preview
- [x] 2.2 `TransferRepository.workflow` reads a project's workflow states

## 3. Application

- [x] 3.1 `ImportDraft`: steps, column and value choices, policies, mode, the JSON mapping
- [x] 3.2 `ImportWizard`: dry runs between steps, commit, back, start over
- [x] 3.3 `importErrorsCsv`

## 4. Screens

- [x] 4.1 `ImportScreen`: source, columns, values, preview, result, each with Back and Cancel
- [x] 4.2 The transfer screen's import section opens the wizard on its project
- [x] 4.3 Project settings links to the wizard for a caller with `import`
- [x] 4.4 Route `/manage/transfer/import`

## 5. Strings and docs

- [x] 5.1 Strings in English, Bulgarian, German and French
- [x] 5.2 README feature list and docs

## 6. Tests

- [x] 6.1 Repository: the request body (mapping, format lines, mode)
- [x] 6.2 Application: mapping state and the error CSV
- [x] 6.3 Widgets: every step, error rows, the CSV saved, compact and expanded
