# AGENTS.md

Coding standards for tix-mobile. Terse by design. Read before writing code.

## Architecture invariants

- `lib/main.dart` bootstraps only. `lib/src/app.dart` is the `MaterialApp.router` with theme and l10n. Nothing
  else goes in either.
- Dependencies point one way: `features/*/presentation` → `features/*/application` → `data/`. `core/` may be used
  by any layer and depends on no feature, with one exception: `core/router` imports feature screens to wire routes.
- A feature never imports another feature. Shared code moves to `data/` or `core/`.
- Widgets never call a repository or the API client. They read providers.
- Providers never build widgets and never speak HTTP. They call repositories.
- `lib/src/data/` imports no Flutter widget library and no Riverpod.
- Only the API client speaks HTTP. It marshals, maps errors and nothing else: no validation, no business rules.
  The server decides.
- Every listing is keyset-paginated with tix's `cursor` and `next_cursor`. Never page by offset.
- Quick add sends the line with `"parse": true`. Never parse tix's quick-add syntax on the client.
- API tokens live only in platform secure storage. Never in preferences, files, logs, crash reports or test
  fixtures that look real.
- Every user-visible string comes from `lib/l10n/`, in English and Bulgarian in the same change.
- Layout adapts to window width, never to `Platform.isX`. Platform checks are for platform services only.
- Generated code is committed and never edited by hand. `just gen-check` fails while it is stale.

## Dart style

- `dart format`. No exceptions.
- The analyzer and lint rules in `analysis_options.yaml` are errors, not suggestions. Do not add `// ignore:`
  without a comment giving the reason.
- Providers use `riverpod_annotation` codegen. Async state is `AsyncValue`; widgets handle loading, data and error.
- `ref.watch` in `build`, `ref.read` in callbacks, `ref.listen` for side effects only.
- Models and DTOs are immutable. JSON mapping is generated.
- Errors are typed values, mapped once in the API client. Never `catch (e)` to swallow.
- Prefer `const` constructors and small widgets over helper methods returning widgets.
- New dependencies need a reason in the PR description, and a check that they support every platform we ship.

## Comments

- One line of doc comment on public members. No essays.
- No commentary inside method bodies. If code needs explaining, rename or restructure it.
- Comment only what the code cannot say: a non-obvious invariant, a deliberate trade-off, a platform quirk.

## Tests

- `test/` mirrors `lib/src/`. New behaviour ships with its test in the same change.
- Unit tests for data and application, widget tests for presentation, goldens sparingly and on Linux only.
- No real network, no real secure storage, no real preferences. Override providers.
- Cover loading, data, empty and error for every screen that has them, at a compact and an expanded width.
- Coverage floor is 80% of `lib/`, generated code excluded. `just cover-check` enforces it.
- A fix for a user-reported bug lands with a test that fails on the old code.

### Watch the guard fail

A test you have not watched fail is not evidence. Break the behaviour it protects, run only that test, read the
failure, restore, and finish with `git diff -- <file>` empty. Most broken guards assert on something wider than
the thing they name: scope finders with `find.descendant`, assert state rather than existence, and assert that a
fake was called. [docs/testing.md](docs/testing.md#watch-the-guard-fail) has the traps.

## Never touch a real server

- Tests never reach a tix server. Hand verification uses a throwaway one: `tix demo seed --db "$dir/tix.db"` and
  `tix serve --db "$dir/tix.db"`, in a directory named for you.
- Never point a development build at a server holding real work with a token that can write.

## Specs

- OpenSpec is normative. Behaviour changes update `openspec/` before the code.
- Requirements use SHALL. Every requirement has at least one scenario.
- Requirement text stays under 500 characters, or `openspec validate --strict` fails. Split, do not compress.
- Tick tasks in `tasks.md` as soon as the code ships. `just spec` validates.

## Commits

- Conventional Commits: `feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert`. The PR title is one too;
  release-please reads it.
- Never add `Co-Authored-By` trailers.
- Keep messages concise and human. No template filler.
- Merge agent branches with `--ff-only`. release-please ignores the commits inside a `--no-ff` merge. When a merge
  commit is unavoidable, give it a conventional subject naming what it delivers.

## Parallel agents

- **One worktree and one scratch directory per agent.** Worktrees go in `.worktrees/<task>`, branched from
  `origin/main`. Scratch, throwaway databases and screenshots go in a directory named for that agent.
- **Split by file set, not by feature count.** `lib/src/core/router/`, `lib/src/app.dart`, `lib/l10n/*.arb`,
  `pubspec.yaml`, `pubspec.lock` and the README feature list are touched by nearly every feature. Group features
  that share them under one agent, or run them one after another.
- **Verify lightly per change, fully once per batch.** Locally: `just fmt-check`, `just analyze`, `just gen-check`,
  `flutter test` for the files you touched, `just spec`, and screenshots of the screens you changed. The full suite,
  the builds for every platform and the repository linters run in CI, and `just check` once per batch.
- **Green means every check passes.** `gh pr checks N --json bucket --jq '[.[].bucket]|all(.=="pass")'` prints
  `true`. Do not read the table by eye. Rerun a failed job only for a known flake, and name it in the PR.
- **Rebase once, when it is your turn.** A PR waiting behind another rebases after that one merges, not on every
  merge while waiting.
- **Report early when it runs long.** An agent past an hour reports what is done and what is left.

## Before you push

    just check

Run `just ci` to reproduce the CI suite locally.
