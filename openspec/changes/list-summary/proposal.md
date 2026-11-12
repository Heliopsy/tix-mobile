# Summary line under the task filter

## Why

tix's web task screen opens with one line that says what the list adds up to: "12 to go, 3 done · across 4
projects · 2 held by an agent · 5 waiting on other tasks", with the waiting count a link to those tasks and a
note when finished work is hidden. The app said only the task count and, in the subtitle, how many an agent
holds, so a reader could not tell how much was waiting or that the list was hiding finished work.

## What Changes

- A summary line under the filter, in every drawing, worded as the web words it, with its empty variants
  ("Nothing open.", "Nothing on the list.", "All clear. Everything here is done.").
- "N held by an agent" moves from the subtitle into that line, still in the accent.
- "N waiting on other tasks" is a button that adds `is:waiting-on` to the filter.
- A list hiding finished work says "open work only" and offers "show finished too".
- The filter language takes `is:waiting-on`, tix's alias of `is:blocked` since v0.57.0.
- The counts are of the loaded rows, as the web counts a page it has no tally for. heliopsy/tix#323 lets the
  listing return the whole selection's tally; once a release carrying it is pinned, the line reads that
  instead.
