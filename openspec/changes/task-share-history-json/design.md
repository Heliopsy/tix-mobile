# Design

## Share

One function, `shareTask`, draws the menu as an action sheet and acts on the choice, so the task header, the
row and card menu and the palette share it. The link prefers the task's `web_url` (set when tix has
`server.public_url`), as `tix task link` does, and falls back to the connection's base URL, which is what the
reader typed to reach the server.

Share… is offered where the platform has a share sheet (Android, iOS, macOS, Windows) and left out on Linux,
the way the web hides it in a browser without `navigator.share`. That is a platform-service check, which the
layout rules allow.

## Raw and Copy JSON

The audit screen already keeps the JSON tix sent for each entry and draws an entry's detail. The detail moves
to `core/widgets` so the task feature can use it without importing the audit feature, and the task history
request keeps its wire JSON the same way. A history row whose JSON was not kept (a cached copy) draws Raw
without Copy JSON.
