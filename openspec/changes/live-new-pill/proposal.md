# Keep the reader's place when tasks arrive above

## Why

When a live event refreshed the task list while the reader was scrolled down, tasks the refresh put above them
pushed every row down, so the row they were reading jumped out from under them. tix's web list holds the reader's
row in place and says "3 new, show" instead (`assets/live.js`, `livePill`). The app had no such thing.

## What Changes

- A `NewRowsPill` design component: "N new, show", floating over the top edge of a list.
- The task list keeps tasks that a refresh puts above the first line in view out of the list while the reader is
  scrolled away from the top, and floats the pill with their count. Pressing it draws them and scrolls to the top;
  scrolling back to the top draws them too. At the top a refresh draws new rows at once, as before.
- `PagedListView` takes an optional `ScrollController`.
- docs/design.md names the component and the behaviour. Strings in English, Bulgarian, German and French.
