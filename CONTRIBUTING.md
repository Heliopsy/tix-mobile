# Contributing to tix-mobile

## Getting started

```sh
git clone git@github.com:heliopsy/tix-mobile.git
cd tix-mobile
just setup     # toolchain from .tool-versions, dependencies, generated code
just run       # on the first available device; just run -d linux for the desktop
```

Requirements: [just](https://just.systems/), [asdf](https://asdf-vm.com/) or [mise](https://mise.jdx.dev/) for the
versions pinned in `.tool-versions`, and the platform toolchain for whatever you build on: the Android SDK, Xcode,
the Linux desktop libraries or Visual Studio. [docs/development.md](docs/development.md#prerequisites) has the
list per OS. `just doctor` says what is missing.

You also need a tix server to point the app at. A throwaway one takes three commands; see
[docs/development.md](docs/development.md#a-tix-server-to-point-it-at). Never develop against a server holding
real work.

## Before you push

```sh
just check
```

That runs formatting, the generated-code check, analysis, the tests and spec validation. To reproduce CI locally:

```sh
just ci
```

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>[optional scope]: <description>

Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
```

Types map to semver: `fix:` is a patch, `feat:` a minor, `feat!:` or `BREAKING CHANGE:` a major. Release notes and
version bumps are generated from them, so the type matters.

Do not add `Co-Authored-By` trailers.

## Specs come first

OpenSpec is the normative contract. A change to behaviour updates `openspec/` before the code:

```sh
just spec
```

Requirements use SHALL and every requirement carries at least one scenario. Tick tasks in `tasks.md` as soon as the
code ships.

## Making changes

1. Branch from `main`.
2. Make the change. New behaviour ships with its test in the same commit, and new strings ship in English and
   Bulgarian.
3. `just check` passes.
4. Open a pull request against `main` and fill in the template. Attach a screenshot for any visible change, at a
   phone width and a desktop width if the layout differs.

Pull requests need one approving review and green CI. The PR title must be a Conventional Commit, because that is
what release-please reads.

## Architecture rules

Listed in full in [AGENTS.md](AGENTS.md) and explained in [docs/architecture.md](docs/architecture.md). The ones
most often hit:

- Widgets read providers. They never call a repository or the API client.
- A feature never imports another feature.
- Only the API client speaks HTTP, and it applies no business rules. The server decides.
- Listings use tix's keyset cursors. Never page by offset.
- Quick add is parsed by the server, never on the client.
- Tokens live only in secure storage, and never reach a log.
- Every visible string comes from `lib/l10n/`.

## Server or client?

tix-mobile shows what the tix API returns. If the API returns the wrong thing, or the feature you want needs
something the API does not offer, the issue belongs in [heliopsy/tix](https://github.com/heliopsy/tix/issues). If
you are not sure, open it here and it will be moved.

## Translations

The app ships in English and Bulgarian. Corrections to either are welcome as small pull requests against
`lib/l10n/app_en.arb` or `lib/l10n/app_bg.arb`. A new language is welcome too, as long as you can keep it complete;
open an issue first so it is not done twice.

## Contributor licence agreement

tix-mobile is AGPL-3.0-or-later. Contributions are accepted under the [CLA](CLA.md), which keeps the option of
offering the app under other terms in future, including the terms app stores require. A bot comments on your
first pull request with a one-click signing link.

## Tests

Unit tests for the data and application layers, widget tests for screens, golden tests sparingly. Coverage must
stay at or above 80% of `lib/`, generated code excluded. See [docs/testing.md](docs/testing.md), and read its
section on watching a guard fail before writing one.

## Conduct

Everyone taking part is expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Supporting tix-mobile

There is no donation link, and the Sponsor button brings you here on purpose. The app is free and talks to a server
you run yourself, so there is nothing to subscribe to.

What helps, most useful first:

- **Tell us when it breaks.** A bug report with the device, the OS version and what you tapped is worth more than
  money, because it is the only way a fault on hardware we do not own reaches us.
- **Send a patch.** The sections above cover everything you need.
- **Say it works.** Which platform you run it on, what you use it for, what still gets in the way.

If you represent an organisation that would rather pay for support or a feature than wait for it, mail
<hi@tix.red> and say what you need.
