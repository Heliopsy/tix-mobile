# Proposal

## Why

A refused token or an ended session stops sync and sends the active connection to the reconnect screen, but the
connections list in Settings and the context switcher still draw a refused connection like any other. Someone with
several connections has no way to see which one needs a new credential until they pick it.

0.22.0 also signed sessions out without recording the refusal, so those connections carry no `refusedAt` and would
stay unmarked.

## What Changes

- The instances screen and the context switcher mark a refused connection with a warning icon and "Signed out, sign
  in again" for a sign-in or "Token refused" for a token, read out as one label.
- Tapping a refused connection, in either list or from the command palette, opens its reconnect screen instead of
  switching to it. Its menu offers Sign in again for a token too.
- On start the app marks refused every remote sign-in that holds no session, so a sign-out from 0.22.0 reads like
  one recorded now. `Connection.refused` stays the only thing the lists read.
- Saving a new working credential clears the mark, as it already clears the refusal.
