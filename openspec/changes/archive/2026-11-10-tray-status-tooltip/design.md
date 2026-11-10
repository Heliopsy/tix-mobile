# Design

## What the app knows

Live status, offline sync, the outbox and the unread count exist only for the active context. Other instances
contribute their name, where they are, and when their saved copy last synced (read from offline preferences).
The tooltip therefore says more about the active instance than the rest, and never claims another instance is
live.

## Text

```text
tix · 2 instances connected
work (tix.example.com): synced 2 minutes ago
home (local): offline, 3 changes queued
5 unread in inbox
```

State of the active instance, first match wins: offline (live offline or the server marked out of reach),
syncing, synced *ago*, live, connecting. Queued changes are appended. At most three instances are listed, then
"+N more". Relative times reuse the app's `timeAgo*` strings.

## Throttling

The host compares the lines with what it last sent, sends at once when nothing was sent in the last two
seconds, else keeps the newest lines and sends them when the two seconds are up. A one-minute timer rebuilds so
"synced 2 minutes ago" moves on. The menu is pushed separately, so a tooltip change never rebuilds the menu
(which on Linux would close an open one).

## Linux

tray_manager 0.5 implements `setToolTip` only on Windows and macOS, and its Linux `setTitle` sets the
AppIndicator *label* (text drawn beside the icon), which is not what we want. Its `AppIndicator*` is a hidden
global in the plugin, so the runner finds it another way: at start it resolves `app_indicator_get_type` from the
already loaded library with `dlsym`, and adds a signal emission hook on `new-status`. tray_manager's `setIcon`
switches the indicator to active, which emits that signal and hands the hook the instance. Dart then calls
`setTrayStatus` on `tix/desktop` with a title (the headline) and a body (the other lines):

- `title` is always set. It is the StatusNotifierItem `Title`.
- `tooltip-title` and `tooltip-body` are set when the class has those properties (libayatana-appindicator 0.6.0
  and later). They become the SNI `ToolTip`; without them the library exports no ToolTip, and with them but
  no tooltip title it falls back to the title.

Properties are looked up with `g_object_class_find_property`, so an older library, or the legacy
libappindicator, still gets the title and nothing breaks. No new build dependency: only GObject calls and
`dlsym`.

What hosts do with it:

- KDE Plasma 6 shows `ToolTip` title as the tooltip heading and its body as the text beneath, in plain text, so
  newlines work. `Title` names the entry in the tray's hidden items and settings.
- GNOME with the AppIndicator extension shows no hover text at all; it uses `Title` only as a fallback
  accessible name.

## Windows and macOS

`setToolTip` takes the whole text. Windows' `NOTIFYICONDATA.szTip` holds 127 UTF-16 units; the shell would
truncate mid-line, so instance lines are dropped from the end of the list until it fits, and the last resort is
an ellipsis. macOS has no practical limit.
