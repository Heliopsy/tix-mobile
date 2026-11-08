# Testing

What the suite covers, how to write a test that earns its place, and the coverage floor.

## Run the suite

| Command | What it does |
| --- | --- |
| `just test` | Unit, widget and golden tests |
| `just cover` | The same, with a coverage report under `coverage/` |
| `just cover-check` | Fails when line coverage drops under the floor |
| `just check` | The pre-push gate set, tests included |
| `just ci` | Every CI gate that can run locally |

Run one file or one test while working:

```sh
flutter test test/data/api/tix_api_test.dart
flutter test --plain-name 'next page appends' test/features/tasks/
```

## Layout

`test/` mirrors `lib/src/`. The test for `lib/src/data/api/tix_api.dart` is `test/data/api/tix_api_test.dart`.
Shared fakes and builders live in `test/helpers/`. `fake_tix.dart` is an in-memory tix server behind a Dio
adapter, so tests run the real client.

## Kinds of test

### Unit tests

For the data layer and the application layer: DTO mapping, the API client's error mapping, repositories, and
notifiers. A notifier is tested through a `ProviderContainer` with its dependencies overridden, never through a
widget.

The API client is tested against canned HTTP responses, including the tix error envelope for every `code`, a
non-JSON body, and a timeout. Copy response bodies from tix's API documentation or a real server, not from memory.

### Widget tests

For screens and components. Pump the widget inside a `ProviderScope` with overrides for the providers it reads,
and assert what a user sees: text, enabled state, what a tap does. Cover the loading, data, empty and error states
of every screen that has them.

Adaptive layouts are tested at least at a compact and an expanded width, by setting the test view's size.

### Golden tests

For things that are cheaper to check as a picture than as assertions: themes, a task card, the layout switch.
Goldens live under `test/**/goldens/` next to the test that owns them.

- Golden images depend on the platform's font rendering. They are generated and compared on Linux, the platform CI
  runs on, and a golden test skips elsewhere. Do not commit goldens generated on macOS or Windows.
- Update them with `flutter test --update-goldens <path>` and look at every changed image before committing it.
  A golden updated without being looked at proves nothing.
- Keep goldens few and small. A golden that changes with every unrelated tweak gets updated blindly and stops being
  a test.

## Rules

- New behaviour ships with its test in the same change.
- No real network. Tests never reach a tix server; integration against a live server is a manual check, against a
  throwaway database (see [development.md](development.md#a-tix-server-to-point-it-at)).
- No real secure storage or shared preferences. Override the providers that wrap them.
- Anything time-dependent takes a clock it can be given. Never sleep to wait for something; pump the frames or
  await the future.
- A fix for a user-reported bug lands with a test that fails on the old code. Watch it fail, as below.

## Watch the guard fail

A test you have not watched fail is not evidence. Before a guard counts as written: break the behaviour it
protects, run only that test, read the failure, and restore. Finish with `git diff -- <file>` empty, so the restore
is checked against git and not against a backup you took.

tix learned this the expensive way: fourteen of its guards passed while the code they protected was broken. Nearly
all failed the same way, by asserting on something wider than the thing they named. In a widget test that looks
like:

- `find.text('Overdue')` passing because the word appears in a filter chip, not on the task it is about. Scope the
  finder with `find.descendant` to the widget you mean.
- `findsOneWidget` on a button that is present but disabled. Assert the state that matters, not only existence.
- An error state test that passes because the loading spinner was never replaced, so the error text was never
  checked against anything. Pump until settled and assert the absence of the previous state too.
- An override that never took effect because the provider read in the widget is a different one from the provider
  overridden. A test whose fake is never called proves nothing; assert the fake was called.

Two more traps, both general:

- **A mutation that does not mutate looks like a working guard.** Check the edit to the code landed before
  trusting the green run.
- **A second check can mask the one you are testing.** If two things stop the same outcome, removing one changes
  nothing observable. Assert both halves: the affordance is absent and the call was never made.

## Coverage

The floor is **80%** line coverage across `lib/`, excluding generated files (`*.g.dart`, `*.freezed.dart`, and the
generated localisation classes). `just cover-check` fails under it, and CI uploads the report to
[Codecov](https://codecov.io/gh/heliopsy/tix-mobile).

The floor is a backstop, not a target. A change that adds code without tests and stays above 80% only because older
code is well covered is still missing its tests.
