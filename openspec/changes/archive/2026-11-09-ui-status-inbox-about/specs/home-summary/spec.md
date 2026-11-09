# home-summary

## ADDED Requirements

### Requirement: Summary tiles keep their size

A summary tile's size SHALL NOT depend on its count. Tiles in a row SHALL share their width and height, and four
SHALL share a row only while each keeps room at the current text scale, else two. Counts SHALL use tabular
figures, read in full below 1000 and in the locale's compact form from there, and SHALL never wrap.

#### Scenario: Nine to a hundred

- **WHEN** the overdue count goes from 9 to 10, then 100
- **THEN** no tile changes size or position

#### Scenario: A large count

- **WHEN** 1234 tasks are open and the language is English
- **THEN** the tile reads 1.2K and a screen reader hears 1,234

#### Scenario: Large text

- **WHEN** the text scale is 200% on a 400 pixel wide phone
- **THEN** the tiles sit two to a row and nothing overflows
