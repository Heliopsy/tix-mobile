# Row marks like the web

## Why

tix's web list and board say four things about a task on its row that the app left out: who holds its claim, that
a claim ran out and how often it has been taken, that it repeats, and how far its checklist is. The app also said
only "waiting on another task" for a task blocked by a dependency, where the web names the task it waits on.

## What Changes

- New design-system marks: `HeldMark` ("held · @atlas"), `ClaimExpiredMark` ("claim expired · 3 h ago · 4 claims"),
  `RepeatMark` (the repeat glyph and the rule), `ChecklistMark` ("3/5", ok once all are ticked) and `WaitMark`
  ("waiting on AICP-12", or "waiting on 2 tasks").
- `TaskRow` and `TaskCard` draw them after the deadline in the web's order. The claim reads as the web reads it:
  held while the lease runs or when there is no lease, expired for a day after `lease_expired_at`.
- The waiting mark replaces the row's blocked glyph before the title, stays in the danger colour, and opens the
  first task it waits on when tapped.
- `TaskFacts.holderHandle` carries the handle of the holder, or of the last holder after an expiry.
