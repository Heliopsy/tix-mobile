# Proposal

## Why

tix's web interface has a (?) at the end of every screen's header that opens the documentation section about that
screen, for the release the server runs. The app has per-field (i) explanations on the connect screen but nothing
that says where to read more about a screen, so someone looking at the trash or the webhooks has no way from the app
to the page that explains them.

## What Changes

- Every screen drawn as a `TixPage` inside the signed-in app gets a (?) button in its header: the last tool on a
  wide window, the last app bar action on a phone. It is a 48 dp button labelled "Help: <screen title>", the
  wording the web uses.
- Pressing it opens the tix documentation section for the screen in the browser:
  - signed in to a remote server: `<server address>/docs/<page>?section=<anchor>`, tix's public documentation
    redirect, so the reader lands on the docs of the release the server runs without the app knowing it;
  - on a local instance, or with no server: the docs on GitHub at the embedded engine's release tag, or at `main`
    when that is not a release.
- One map in `core/help` names the page and heading for every routed screen, reusing the web's anchors from
  `internal/web/help.go` where the screens match. App-only screens (offline storage, sync conflicts) map to
  nothing and draw no button.
- `TixPage` reads the button from a `TixPageHelp` scope set once around the routes, so no screen file changes.
  A page drawn inside another page (a list's detail pane) does not repeat it.
- A new design component, `ScreenHelpButton`, with a gallery entry.
- The anchors are checked against tix's docs at the commit `tix.lock` pins, vendored as
  `api/tix-doc-anchors.json` by `just doc-anchors-sync`.

## Impact

- Capabilities: `screen-help` (new).
- Code: `core/help/screen_help.dart`, `core/design` (`TixPage`, `TixPageHelp`, `ScreenHelpButton`),
  `core/router/router.dart` (one wrapper), `tool/doc_anchors.dart`, `api/tix-doc-anchors.json`, gallery.
- No tix change: `GET /docs/{page}` is a public route since tix 0.44 and takes `section` since 0.46.
