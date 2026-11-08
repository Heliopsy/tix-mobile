# Documentation

Guides for building, changing and releasing tix-mobile. [`openspec/`](../openspec/) is the normative behaviour
contract and the [README](../README.md) is the front door. These pages sit between the two.

For the server, its API and its CLI, see [tix's documentation](https://github.com/heliopsy/tix/tree/main/docs).

## Guides

| Guide | Covers |
| --- | --- |
| [development.md](development.md) | Prerequisites per OS, asdf and mise, every `just` recipe, codegen, localisation, emulators and desktops, screenshots |
| [architecture.md](architecture.md) | Layers, state management rules, navigation and the adaptive shell, error mapping, keyset pagination, quick add |
| [design.md](design.md) | Tokens, the tenant accent, every component and when to use it, the UX rules, accessibility, the new-screen checklist |
| [testing.md](testing.md) | Unit, widget and golden tests, watching a guard fail, the coverage floor |
| [widgets.md](widgets.md) | Home screen widgets: platforms, data flow, the snapshot contract |
| [releasing.md](releasing.md) | release-please, version numbers, artifacts and provenance, signing secrets, recovering a failed release |

## Where to start

- First build: [development.md](development.md#prerequisites), then `just setup` and `just run`.
- Adding a screen: [design.md](design.md#building-a-new-screen), [architecture.md](architecture.md#layers), then
  [testing.md](testing.md#widget-tests).
- Adding a string: [development.md](development.md#localisation).
- Cutting a release: [releasing.md](releasing.md).
- Coding standards in one page: [AGENTS.md](../AGENTS.md).
