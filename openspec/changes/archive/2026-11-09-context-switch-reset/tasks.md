# Tasks

## 1. Session

- [x] 1.1 `ContextMoves` hooks and `activate(..., landing:)`; a move to another context leaves, activates, lands
- [x] 1.2 Forgetting the active connection or instance moves the same way

## 2. Router

- [x] 2.1 Hosts in a `ShellRoute` around the `StatefulShellRoute`, with `/switching` beside it
- [x] 2.2 `redirectFor` holds everything on `/switching` while moving; `landingFrom` picks the tab root
- [x] 2.3 The router fills `ContextMoves`: pop root sheets, go to `/switching`, wait a frame, land

## 3. Targeted switches

- [x] 3.1 `DeepLinkHost` lands on the link's route
- [x] 3.2 `WidgetSync.open` lands on the widget's route

## 4. Tests

- [x] 4.1 `redirectFor` while moving and `landingFrom`
- [x] 4.2 Session: leave before, land after, nothing for the same context or a refused switch
- [x] 4.3 App: switching on a task, a link into another tenant, the same context again, sheets closed
