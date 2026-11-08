# Tasks

## 1. Data

- [x] 1.1 Inbox, channel, delivery and stats models; API client methods for the 14 inbox operations and stats
- [x] 1.2 `InboxRepository`; fake inbox, channels and stats in `test/helpers/fake_tix.dart`

## 2. Live

- [x] 2.1 Inbox, badge and notifications follow the event stream (`refreshOn`, `onEvents`)
- [x] 2.2 `UpdatedMark` and `ChangedElsewhereBanner` components with gallery entries and goldens

## 3. Inbox

- [x] 3.1 Inbox list, count, prefs, channels and summary providers
- [x] 3.2 Inbox screen: groups, filters, marking, swipe, menu, mark all read, opening the task, summary card
- [x] 3.3 Inbox tab with the unread badge; commands
- [x] 3.4 Channels screen and deliveries

## 4. Notifications

- [x] 4.1 `LocalNotifier` over flutter_local_notifications; Android, iOS and macOS setup
- [x] 4.2 `InboxNotifications`: new items notify once, taps open the task
- [x] 4.3 Settings: notifications per context and per kind, inbox kinds muted on the server

## 5. Docs

- [x] 5.1 `docs/design.md`: what push would need from tix
