# Design

## Context

A new public Flutter client for tix on Android, iOS, Linux, macOS and Windows. The server is the Go project
`heliopsy/tix`; this app consumes its `/api/v1` HTTP API with a bearer token and nothing else.

## Goals / Non-Goals

**Goals:** a stack that will still be the obvious one next year; a layout every later feature can follow;
one vertical slice (connect, browse, quick add, settings) that runs against a real server.

**Non-Goals:** editing tasks beyond quick add, the event stream, offline storage, password or SSH sign-in,
push notifications.

## Decisions

### State: Riverpod 3 with riverpod_generator

`@riverpod` providers keep dependencies explicit and overridable, which is what makes every screen testable
with a fake server. Riverpod 3 retries failed providers by default; the app turns that off (`noRetry`)
because every error view has a retry button and a refused token does not start working by waiting.

riverpod_lint 3 is an `analysis_server_plugin`, configured under `plugins:` in `analysis_options.yaml`.
custom_lint is no longer needed. The plugin runs under `dart analyze`, not `flutter analyze`, so CI should
run `dart analyze`.

### HTTP: Dio over package:http

- An `HttpClientAdapter` is the seam for tests: `test/helpers/fake_tix.dart` is an in-memory tix behind
  one, so widget tests run the real client, real JSON and real error mapping.
- Per-instance base URL, headers and connect/receive timeouts, one client per saved server.
- `DioException.type` tells timeouts, refused connections and bad responses apart, which the error
  mapping needs.

`package:http` would need a hand-rolled timeout and error layer for the same result.

### Models: freezed + json_serializable

The API's JSON is snake_case with many optional fields. `build.yaml` sets `field_rename: snake` and
`include_if_null: false` once, and freezed gives value equality for provider state. `Page<T>` is written by
hand: it is ten lines, and generic `fromJson` through codegen costs more than it saves.

### Material: `package:material_ui`

Material has moved out of the framework into `material_ui`, and go_router and flutter_riverpod already
import it. The app imports `material_ui` everywhere. flutter_markdown_plus still reads the framework's
legacy `Theme`, so the one `MarkdownBody` sits under `MaterialUiCompatibilityBridge` until it migrates.

### Lints: very_good_analysis plus strict modes

`strict-casts`, `strict-inference` and `strict-raw-types` are on. Two rules are off:
`public_member_api_docs` (an app, not a library) and `unnecessary_type_name_in_constructor`, which asks for
Dart 3.13's `new(...)` constructors that freezed does not parse yet.

### Secrets and settings

The API token goes to `flutter_secure_storage` under `token.<context id>`, never to preferences. Saved
servers (name, address, handle) and theme and language go to `SharedPreferencesWithCache`. On macOS the
legacy keychain is used (`usesDataProtectionKeychain: false`) so the app needs no keychain-sharing
entitlement or provisioning profile. Both stores sit behind small interfaces (`KeyValueStore`,
`SecretStore`) so tests use in-memory ones.

### Connecting

`GET /healthz` first, without the token: a 404 or a non-JSON answer means the address is not tix, which is
a different message from a refused token. Then `GET /api/v1/whoami` with it. Connecting again to the same
address as the same handle replaces the saved context rather than adding a second.

### Lists

Every tix list is keyset paginated: `limit`, `cursor`, `next_cursor`. `Paged<T>` holds the rows so far and
the next cursor; `loadNextPage` appends a page and keeps a failure on the state, beside the rows already
shown, so the footer can offer a retry. `PagedListView` asks for the next page five rows before the end.

### Quick add

`POST /api/v1/tasks` with `project_ref` set to the open project and `"parse": true`. The server owns the
syntax, so the app never drifts from the CLI and web. A line that names another project (`+web`) is a 400
from the server, shown under the field with the line kept.

### Layout

| Width | Navigation | Tasks |
| --- | --- | --- |
| < 600 | bottom bar | list, task on its own route |
| 600 to 839 | rail | list, task on its own route |
| >= 840 | rail (labels beside icons from 1200) | list and task side by side |

The task route `/projects/KEY/tasks/REF` is the same at every width; on a wide screen its page is the list
with that task open beside it.

### Generated files are committed

`*.g.dart`, `*.freezed.dart` and `lib/l10n/generated/` are in git so a fresh clone analyzes and builds
without running codegen. CI regenerates and diffs. The `combining_builder` preamble and the `l10n.yaml`
header put the SPDX line in `*.g.dart` and the localizations; freezed's builder takes no header, so
`*.freezed.dart` files need a REUSE annotation. build_runner 2.17 dropped `--delete-conflicting-outputs`;
`dart run build_runner build` is enough.

## Risks / Trade-offs

- `MaterialUiCompatibilityBridge` is deprecated. It goes when flutter_markdown_plus moves to `material_ui`
  or is replaced.
- Riverpod 3 and `material_ui` are both young; the lockfile pins exact versions.
- Assignee names cost one `GET /actors/ID` each, cached per session. A list view showing names would want a
  batch read.
