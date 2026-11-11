# Design

## No API call

The web's Hand to an agent is copy-ready text built in `internal/handoff`; the browser never claims anything
(`ClaimTask` and `ClaimNext` are exempt from the web UI as the agent work queue). The app does the same: the text is
built in `features/tasks/application/handoff.dart`, a port of `internal/handoff`, and the sheet only copies it. No
operation binding changes.

## Same words as the web

The prompts, the client list and the POSIX quoting follow `internal/handoff` word for word, and the prompts stay in
English in every locale as they do on the web, because an agent reads them. The labels around them are translated.
A project reference shows in capitals as `output.ShowRef` does.

## The server address

The web names the address the request reached. The app names the session's base URL: the remote address, or the
local engine's loopback for a local instance, which an agent on the same machine can reach.

## Where it lives

A header icon beside star and snooze, as the web puts the button in the task header, plus the task menu and a
palette command without a key: the web binds no key to it, and the free single letters clash with presets. A task
created offline and not yet sent has no reference the server knows, so none of the three is offered for it. The web
has no list row or bulk entry for it, so neither does the app.
