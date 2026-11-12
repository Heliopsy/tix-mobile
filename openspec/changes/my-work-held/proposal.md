# My work: tasks I hold, and an overdue badge

## Why

tix's web My work has an "Include tasks I hold" switch that adds the tasks the reader has claimed to the ones
assigned to them, and its sidebar entry carries a red count of the reader's overdue tasks. The app had neither, so a
reader who claims work rather than being assigned it could not see it in one place, and nothing outside My work said
something was late.

## What Changes

- My work gets an "Include tasks I hold" chip. On, it asks for the tasks `claimed_by=me` as well, with the same
  filter, and adds the ones it does not already list after the assigned ones, as the web's `withHeld` does.
- The My work navigation destination shows how many of the reader's open assigned tasks are overdue, in the danger
  colour, "99+" past 99, and nothing at zero. The count is one small `assignee=me due:overdue` request for open states,
  refreshed when tasks change.
