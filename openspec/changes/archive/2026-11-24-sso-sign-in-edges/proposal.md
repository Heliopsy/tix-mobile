# Proposal

## Why

The first cut of provider sign-in has edges where it loses a sign-in or says the wrong thing:

- On Android, if the system ends the app while the Custom Tab is open, the redirect restarts it and is dropped,
  because nothing listens yet.
- Server reasons show raw ("did not finish (not_linked)"), with a Retry that cannot help a person the tenant does
  not know.
- Linux offers the buttons without a `red.tix.mobile` scheme handler, then waits for ever.
- A redirect from an older browser tab ends a newer attempt with "could not be verified".
- Cancel during the code exchange still saves the session.
- Windows ignores a failed `reg` write.
- Android counts a return as a cancel 2 seconds after resume, which a slow phone can beat.

## What Changes

- The attempt (server, provider, verifier, state, start time and what the connect screen was for) is kept in secure
  storage while the browser is open and cleared when it ends. A redirect that arrives with nobody listening is
  held. On restart the connect screen finishes the kept attempt when the held redirect matches it and its code is
  under two minutes old; otherwise it says the sign-in was interrupted. With a session already open, the held
  redirect opens the connect screen the attempt started from.
- `access_denied` returns quietly to the form. `not_linked` and `expired` get messages of their own, and
  `not_linked` offers no Retry. Any other reason says the sign-in did not finish, without the code.
- Linux offers provider sign-in only when `xdg-mime` names a handler for `x-scheme-handler/red.tix.mobile`, or in a
  Flatpak. Linux and Windows stop waiting after 5 minutes with the expired message.
- Redirects whose state is not the live attempt's are ignored and the wait goes on.
- A cancel during the exchange saves nothing.
- A failing `reg` fails the sign-in before the browser opens.
- The Android grace after resume is 5 seconds.
