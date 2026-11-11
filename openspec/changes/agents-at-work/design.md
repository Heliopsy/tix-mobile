# Design

## Same count as the web

The web's `summarise` counts a row as held when `ClaimedByActorID` is set and `LeaseExpiresAt` is after now. The app
counts the loaded rows with the same test, reading now from `clockProvider`. A claim with no lease is not counted,
as on the web. The web counts the page it rendered; the app counts the rows it has loaded, which is the same set
until the reader scrolls for more.

## Where it shows

The web puts it in the lede under the heading. The app's equivalent is the `TixPage` subtitle: under the app bar title
on a phone, under the page title on a wide window. The subtitle stays a plain string, and the note is a second span
after a middle dot, coloured with `context.tix.accent` as `.summary .held` is with `--accent`. It is plain text, as
on the web: tapping it does nothing.

## Live

No new request. The listing provider already refreshes on the claim topics, so a claim or release elsewhere changes
the count without a pull. A lease that lapses before the sweeper runs drops out at the next rebuild, as it drops out
of the web's line at the next render.
