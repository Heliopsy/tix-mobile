# Proposal

## Why

Three things people noticed on a phone:

- The live status in the context bar sat in the middle of the bar. The name took only half the free space and
  the indicator followed it, so it floated away from both the text and the edge.
- The inbox summary tiles changed size as their numbers grew. A count that no longer fit wrapped onto a second
  line, so going from 99 to 100 made a tile, and the row with it, taller.
- About had no place under More. It was only reachable from Settings and the command palette.

## What Changes

- The live status follows the context's name on the same line, starting where the text ends, with the live dot
  at the start of its target. The rail's corner badge sits at the avatar's end corner, so it flips with the
  writing direction.
- Summary tiles take their width from the row and their number box is one line tall. Counts use tabular figures,
  read in full below 1000 and in the locale's compact form from there ("1.2K"), and scale down instead of
  wrapping. Tiles in a row share a height, and four share a row only while each keeps room at the current text
  scale.
- More ends with About on a phone, and the rail ends with an About button on anything wider.

## Impact

- Capabilities: changed `live-updates`, `home-summary`, `about`, `adaptive-layout`.
- Design system: `LiveIndicator.leading` and `compactCount`. The goldens do not change: the default alignment is
  kept.
- No new strings: the entries reuse `aboutTitle`, already in all four languages.
