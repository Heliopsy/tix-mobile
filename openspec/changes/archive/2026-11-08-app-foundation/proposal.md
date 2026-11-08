# Proposal

## Why

tix has a CLI, a terminal UI and a web app, but nothing that sits on a phone or a desktop dock. The repository
holds only the `flutter create` scaffold. This change lays the foundation every later feature builds on: the
stack, the layout of `lib/`, and a thin but real slice against the tix HTTP API.

## What Changes

- Pick and pin the stack: Riverpod 3 with code generation, go_router, Dio, freezed and json_serializable,
  flutter_secure_storage, shared_preferences, gen-l10n, `material_ui`, dynamic_color and very_good_analysis.
- Connect to a tix server with its address and an API token, checked against `GET /healthz` and
  `GET /api/v1/whoami`. Several servers can be saved and switched between, like `tix ctx`.
- Browse projects, a project's tasks (keyset paginated, pull to refresh) and one task, with its description
  drawn as Markdown.
- Quick add a task in tix's one-line syntax, parsed by the server (`"parse": true`).
- Settings: theme mode, language (English, Bulgarian) and sign out.
- A bottom navigation bar on phones, a navigation rail and a list beside the open task on wide screens.
- Map the tix error envelope to typed errors and to messages in the reader's language.

## Capabilities

### New Capabilities

- `server-connection`: signing in to a server, saving several, switching and signing out.
- `task-browsing`: projects, a project's tasks and one task.
- `quick-add`: creating a task from a quick-add line.
- `app-settings`: theme mode and language.
- `adaptive-layout`: navigation and panes by screen width.
- `api-errors`: how a failed call reaches the reader.

### Modified Capabilities

None; there are no specs yet.

## Impact

- New code under `lib/src`, `lib/l10n` and `test/`, plus `pubspec.yaml`, `analysis_options.yaml`,
  `build.yaml` and `l10n.yaml`.
- Platform: the Android `INTERNET` permission and `minSdk` 23 (flutter_secure_storage), the macOS
  `network.client` entitlement. The Linux build needs the libsecret development package.
- Generated code (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated/`) is committed.
