# Tasks

## 1. Tokens and theme

- [x] 1.1 `TixTokens` with light, dark and dim, `lerp`, project, status and priority colours
- [x] 1.2 Spacing, radii, sizes, type scale, measures and motion constants
- [x] 1.3 `buildTixTheme` mapping the tokens onto Material 3 and its component themes
- [x] 1.4 Remove dynamic colour

## 2. Tenant accent

- [x] 2.1 `TixAccent` with tix's built-in themes and custom derivation, checked against tix's own values
- [x] 2.2 `Tenant.theme`, `TenantRepository` and `tenantAccentProvider`, remembered per context
- [x] 2.3 `App` follows the accent

## 3. Components

- [x] 3.1 Page scaffold and header, buttons and icon buttons
- [x] 3.2 Task row, task card, tick, status pill, priority mark, tag, project, avatar, badges, due and snooze marks
- [x] 3.3 Empty, error and skeleton states; sections and (i) tips
- [x] 3.4 Text and search fields, switch rows, filter bar, quick add
- [x] 3.5 Adaptive sheet, confirm, action sheet, toast and `runOptimistic`
- [x] 3.6 Swipe actions and haptics
- [x] 3.7 Command registry, shortcuts, `?` help and command palette

## 4. Screens

- [x] 4.1 Projects, task list, task detail and quick add
- [x] 4.2 Settings, instances, the switcher and the shell
- [x] 4.3 Existing tests updated for the new widgets

## 5. Gallery, goldens and docs

- [x] 5.1 `/gallery` in debug and profile builds
- [x] 5.2 Goldens, light and dark at 400 and 1280, and a tenant accent; `just goldens`
- [x] 5.3 `docs/design.md`, the UI rules in `AGENTS.md`, development and testing notes
