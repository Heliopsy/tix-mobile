# Tasks

## 1. Stack

- [x] 1.1 Add the dependencies at their latest versions and confirm `flutter pub outdated` holds nothing back without reason
- [x] 1.2 very_good_analysis with strict-casts, strict-inference and strict-raw-types; riverpod_lint as an analyzer plugin
- [x] 1.3 build.yaml (snake_case JSON, SPDX preamble) and l10n.yaml (English, Bulgarian)
- [x] 1.4 Migrate imports to `package:material_ui`
- [x] 1.5 Android INTERNET permission and minSdk 23; macOS network.client entitlement

## 2. Data

- [x] 2.1 Models: Actor, Project, Task, CreateTaskRequest, Health, ServerContext, Page
- [x] 2.2 TixApi over Dio: healthz, whoami, projects, tasks, task, actor, create task
- [x] 2.3 TixException from the error envelope, status and transport
- [x] 2.4 KeyValueStore and SecretStore with shared_preferences and flutter_secure_storage
- [x] 2.5 ContextsRepository, SettingsRepository, TasksRepository

## 3. Features

- [x] 3.1 Session: connect, switch, sign out; several saved servers
- [x] 3.2 Connect screen
- [x] 3.3 Projects list with pagination and pull to refresh
- [x] 3.4 Task list and task detail with Markdown
- [x] 3.5 Quick add with server-side parsing
- [x] 3.6 Settings: theme, language, servers, sign out
- [x] 3.7 Router with session redirects; adaptive shell and two-pane task view
- [x] 3.8 English and Bulgarian strings, errors mapped to messages, server failures naming their request id
- [x] 3.9 Shared session state in `core/session/`; `data/` free of Flutter widgets and Riverpod

## 4. Tests

- [x] 4.1 API client against an in-memory tix behind a Dio adapter
- [x] 4.2 Repositories, providers and the router's redirects
- [x] 4.3 Widget tests for every screen and the app at phone and desktop widths
- [x] 4.4 Coverage of lib/src above 80%, generated files excluded
- [x] 4.5 Delete the counter test

## 5. Verification

- [x] 5.1 `dart format`, `dart analyze`, `flutter test --coverage` and a clean codegen rerun

The Linux debug build was not run here: the host lacks clang and libsecret-1-dev. CI covers it.
