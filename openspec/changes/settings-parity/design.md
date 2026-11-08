# Design

## Where each setting lives

| Group | Setting | Stored |
| --- | --- | --- |
| This device | Theme, pure black, reduce motion, touch feedback | preferences (`settings.*`) |
| This device | Language | preferences; tix keeps none on the account |
| This device | Start screen | preferences (`settings.start`) |
| This device | Notifications on this device, servers, About | preferences and secure storage |
| Your account | Date format, time zone | tix, `PATCH /me/time` |
| Your account | Inbox kinds, personal channels | tix (existing screen) |
| Your account | Saved filters | tix, `filter.*` (existing operations) |
| Your account | Board, lanes and My work arrangement | tix, `view.reset` for `board`, `lanes`, `mine` |
| This tenant | Everything in the Manage hub | tix, linked, not copied |

The screen is driven by one catalogue (`settings_catalogue.dart`): id, section, label, keywords and an optional
route. Search filters it, the palette registers a command per entry, and the screen maps ids to widgets, so the
three cannot drift. Pending features (people, security, local engine idle, offline, widgets) add an entry and a
widget case.

## Dates

`TixTimeStyle` ports tix's `output.TimeStyle`: the eight named formats, `Date`, `DayMonth`, the clock, and the
zone. The server resolves user > tenant > global and the app takes `effective` as it is, so the order cannot
differ from tix's. An empty effective field (no level set) or a server without `/me/time` leaves the device's
locale formats and zone, which is what the app showed before.

`ReaderTime` (keepAlive) remembers the last settings per context in preferences, so the next start shows dates
the reader's way before the network answers, then refreshes, as the tenant accent does. `App` hands the style to
every screen through `TixTimeScope`; `context.times` adds the words the relative format needs. Day boundaries
(due today, overdue, My work's buckets, the inbox's Today and Yesterday, the summary) count in the same zone, and
a time a person picks is read as a wall clock in that zone.

Zone data is `timezone`'s `latest_all`, which carries the aliases and `UTC` a tix server may hold; the 10-year
set lacks them.

Month and weekday names follow the app's language, unlike tix's English names; the order and digits follow the
format.

## Trade-offs

- Haptics is a static flag on `TixHaptics`: its callers are gesture handlers in components that hold no ref.
- Reduce motion overrides `MediaQuery.disableAnimations` under the router, so `TixMotion.of` and Material's own
  animations both obey it.
- The saved filters screen lives in the tasks feature, beside the menu it reuses, and is routed under
  `/settings/filters`.
