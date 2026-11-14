## ADDED Requirements

### Requirement: Description fields have a formatting toolbar

The description editor and the new task form's description field SHALL offer a toolbar with the web's formatting
tools in its order: bold, italic, strikethrough, heading, bulleted list, numbered list, checklist, quote, code, link
and table. Each tool SHALL edit the Markdown text in the form tix's web writes and SHALL leave every line it does not
act on unchanged. Each button SHALL carry a tooltip and a semantics label.

#### Scenario: Bold a selection

- **WHEN** the selection is `plan` and Bold is pressed
- **THEN** the text reads `**plan**` and pressing Bold again gives back `plan`

#### Scenario: Make lines a checklist

- **WHEN** two lines are selected and Checklist is pressed
- **THEN** both start with `- [ ]`

#### Scenario: Add a link

- **WHEN** the selection is `docs`, Link is pressed and `https://tix.example` entered
- **THEN** the text reads `[docs](https://tix.example)`

### Requirement: Lists continue on Enter

In a description field, Enter at a list item or quoted line SHALL start the next one with the same marker, the next
number, or an unticked box. Enter on an item with no text SHALL remove its marker and end the list. Inside fenced
code Enter SHALL insert a plain newline.

#### Scenario: Next number

- **WHEN** the cursor ends `2. two` and Enter is pressed
- **THEN** a new line starts with `3.`

#### Scenario: End the list

- **WHEN** the cursor is on an item `- [ ]` with no text and Enter is pressed
- **THEN** the marker is removed and no new item starts

### Requirement: Formatting keys in description fields

Inside a description field Ctrl+B, Ctrl+I and Ctrl+` (Cmd on macOS) SHALL toggle bold, italic and code, as on the
web. They SHALL be bound only inside the field. Ctrl+K SHALL keep opening the command palette.

#### Scenario: Ctrl+B

- **WHEN** a word is selected in the description field and Ctrl+B is pressed
- **THEN** the word is wrapped in `**`

### Requirement: The toolbar sits by the keyboard on a phone

On a compact window the toolbar SHALL sit directly under the field, above the on-screen keyboard; on a wider window
it SHALL sit above the field. In Preview the toolbar SHALL be hidden.

#### Scenario: Compact width

- **WHEN** the description editor opens at 400 dp wide
- **THEN** the toolbar is drawn below the text field
