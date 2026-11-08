# Design

## Context

tix's browser interface has a deliberate look: a white page with tinted recessed regions, hairlines instead of
shadows, one filled accent button per screen, and markings on a task row that differ by shape as well as colour.
Its stylesheet documents why each value is what it is. The app should look like the same product.

## Decisions

### Tokens as a theme extension

`TixTokens extends ThemeExtension<TixTokens>` holds every token for one scheme, with `lerp` so a theme change
animates. `buildTixTheme` maps them onto a hand-built `ColorScheme` and a theme for every Material component the
app uses. Screens read `context.tix` for anything Material has no role for (status colours, project colours, the
soft tints). Material 3 stays underneath for its widgets, focus and accessibility; tix's values override its
defaults, so no surface tint, no elevation on cards or app bars, and the accent filled only on primary actions.

### The tenant accent

tix stores a theme name on the tenant (`theme`), and resolves it in `core.ThemeRegistry.Resolve`: a built-in
name, a `#rrggbb` derived by `CustomTheme`, or the default. The app ports the built-ins and the derivation and
checks them against values printed by tix. The only way to read a tenant's theme is `GET /tenants/{ref}`, which
needs `tenant:admin`; a narrower credential keeps the default. A theme only the server's configuration defines
cannot be read and falls back to the default too. The last accent seen for a context is kept in preferences so
the app opens in it.

The web paints the in-progress status in the accent. The app keeps it on tix's own teal, because tix's rule is
that state colours are not themeable, and a tenant that brands itself orange should still read "doing" the same
way everywhere. `withAccent` also moves an accent that falls under 4.5:1 on the page (forest's light accent), the
rule tix already applies to custom accents.

### Dynamic colour is dropped

Android's wallpaper colours replaced tix's identity and any tenant accent. They cannot both win, and tix's
theming docs make the tenant's accent the one that counts.

### Components in core, one barrel

Components live in `core/design/components/` and are exported from `core/design/design.dart`, so a feature
imports one file and cannot reach for a private styling helper of another feature. Each has a doc comment saying
when to use it; `docs/design.md` is the index and the rules.

### Touch adaptations of tix's web rules

A create action is a primary header button that opens a dialog on the web. On a phone the header is an app bar
and the thumb is at the bottom, so the same action renders as an extended floating button with its icon and
label, and its form opens as a bottom sheet (`showTixSheet`). Confirmations stay dialogs, which is the norm on
both mobile platforms.

### Keyboard

`TixShortcuts` wraps the signed-in shell. Screens register `TixCommand`s with `CommandScope` for as long as they
are mounted; the same list feeds the `?` help and the Ctrl+K palette. Keys typed into a text field stay there.

### Goldens

Goldens need real glyphs to be worth looking at. Roboto and the Material icons are loaded from the pinned Flutter
SDK's own cache by a `flutter_test_config.dart` scoped to `test/core/design/`, so nothing is vendored and other
tests keep the default test font.

## Risks

- A tenant theme read needs `tenant:admin`. Most people's sessions will see tix's default until tix exposes the
  resolved accent to every member (for example on `whoami`).
- Goldens depend on the pinned Flutter's Roboto. A Flutter upgrade may move them, and they are regenerated then.
