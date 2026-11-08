# Roadmap

The first slice is in [README.md](README.md#features): connect to a server, projects, task lists, task detail, quick
add and settings, on five platforms. Below is what comes after it, in no fixed order, with what each item needs and
what is still undecided.

Nothing here is promised by a date. Each item gets an OpenSpec change before work starts, and that change is where
the decisions below get made.

## Live updates

Subscribe to the tix event stream (`GET /api/v1/events`, a WebSocket) so lists and the open task update when
somebody else changes them, without pulling to refresh.

- tix's stream resumes from a cursor (`since_seq`) after a reconnect, so a phone that loses signal catches up
  without gaps. The client keeps the last sequence number per server.
- The token needs `event:subscribe`. The app has to cope with a token that lacks it and fall back to refreshing.
- Mobile operating systems close sockets in the background. The stream runs while the app is in the foreground;
  background delivery is the push notification item below.

## Offline cache

Keep the last-seen projects and tasks on the device, so the app opens instantly and reads without a connection.

- The repositories are the seam: providers do not change.
- Undecided: whether writes made offline are queued and replayed, and how a conflict with a change made on the
  server meanwhile is shown. tix's workflows and leases make a blind replay wrong in some cases.
- The cache holds server data on the device, which changes the security story. It needs encryption at rest and a
  clear wipe on removing a server.

## Push notifications

Mentions, assignments and due dates on the lock screen.

- Needs a server-side sender, because a phone cannot hold a socket open in the background. That is a tix server
  change (registering device tokens, sending through FCM and APNs) before it is an app change, and tix is
  self-hosted, so the design has to work without a hosted relay or make one optional.
- The tix inbox already models what a notification would carry.

## Home screen widgets

My work, Inbox, Quick add and Project shipped on Android, iOS and macOS; [docs/widgets.md](docs/widgets.md) has
the details. What is left:

- Windows 11's widgets board, once the app is MSIX packaged: a Widget Provider reading the same snapshots.
- Interactive ticks that reach the server from a closed Mac app (today they wait for the app to open).
- Ticks on the Project widget, and moving a task to another state from a widget.

## Wear OS

A tile with what is due today and a complication-sized count, plus a small companion app for ticking a task done.

- Native Kotlin. Flutter on Wear OS works for apps but not for tiles.
- The community `wear_os_tiles` plugin may avoid a second codebase for the tile; that needs a spike before it is
  relied on.
- Undecided: whether the watch talks to the phone through the Wearable Data Layer or holds its own token. Keeping
  tokens on one device argues for the first.

## Apple Watch

The same scope as Wear OS: today's tasks and marking one done.

- Native SwiftUI, talking to the iPhone app through WatchConnectivity.
- Flutter does not target watchOS. The unofficial flutter-watchos toolchain exists but is beta, which is not a base
  for something people rely on.
- Needs iOS signing first.

## Store releases

Today releases are files on GitHub. The goal is the stores people already use. The pipeline for each is in the
repository and skipped until its account exists; [docs/releasing.md](docs/releasing.md#store-channels) lists what
each still needs from the maintainer.

| Store | In the repository | Still needs |
| --- | --- | --- |
| Google Play | Store text in four languages, internal-track upload | A developer account, the listing's forms, screenshots, the review |
| App Store | Signed IPA and TestFlight upload | An Apple developer account, a privacy manifest, screenshots, the review |
| macOS (direct download) | Developer ID signing and notarisation | The Developer ID certificate |
| F-Droid | Recipe, tix srclib, a CI check for non-free code | Submission to fdroiddata |
| Flathub | Manifest, AppStream metainfo | Generated offline sources, a test build, screenshots, the submission |

The [CLA](CLA.md) is what lets the maintainer accept app-store terms that sit awkwardly with the AGPL alone.

## Not planned

- **A client-side quick-add parser.** The server parses, so every client agrees with it.
- **Features the tix API does not have.** Those are tix issues first; the app follows.
