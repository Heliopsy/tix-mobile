# Proposal

## Why

The app shows projects and settings and nothing else a team lead needs. Creating or renaming a project, changing
its colour or workflow, archiving it, editing a workflow or defining a custom field all still need the browser.
There is also no one place that says what this credential may manage, so the first sign of a missing scope is a
refusal.

## What Changes

- A Manage destination: every management area the credential can use, grouped (Projects, Workflows, Fields,
  People, Access, Tenant, Server), each entry shown only when `whoami` grants its scope. The list lives in one
  file other features add to.
- The phone's bottom bar keeps at most five destinations; the rest open from a More sheet.
- Projects: create from the projects screen, a settings screen with the web's headed sections (project,
  appearance, claims, fields, danger zone), key changes explained before they are sent, archive, and delete with
  the server's plan (move the tasks with their status mapping, or delete them after typing the key).
- Workflows: list, create, and a phone-friendly editor for states (reorder, label, category, terminal, initial,
  revert on lease expiry), transitions as "can move to" chips with comment and scope rules, routes from the
  initial state, migrations for removed states, delete; the server's refusals shown inline.
- Custom fields: list, define, edit, reorder and delete a project's fields, with a default input for every type.
- The generated client sends an explicit JSON null for a field whose null means "clear" (a task's due date), so
  no request is hand-built.

## Impact

- New capabilities: `manage-hub`, `project-admin`, `workflow-admin`, `custom-field-admin`. Changed:
  `adaptive-layout`, `api-client`.
- Operations bound in the parity registry (wave 2): `project.create`, `project.update`, `project.delete`,
  `project.delete-plan`, `project.icon`, `workflow.list`, `workflow.put`, `workflow.put_by_key`,
  `workflow.delete`, `field.put`, `field.delete`.
- Not in tix's API, so not in the app: unarchiving a project.
