# design-system Specification

## Purpose
How the app looks: tix's tokens and the tenant's accent, the shared components, and the rules every screen follows.

## Requirements

### Requirement: The app looks like tix

The app SHALL draw with tix's design tokens in light and dark: its page and surface colours, text colours,
hairlines, accent, spacing, radii and type scale, in place of Material's defaults.

#### Scenario: Light theme

- **WHEN** the light theme is chosen
- **THEN** the page is white, lists sit on tix's tinted surface and primary buttons are tix's teal

#### Scenario: Dark theme

- **WHEN** the dark theme is chosen
- **THEN** the page is tix's dark page colour and the accent is tix's dark teal

### Requirement: The app follows the tenant's accent

When the active context's tenant names a theme the app can read, the app SHALL use that theme's accent, resolved
as tix resolves it: a built-in name, a custom `#rrggbb` derived for each scheme, or tix's default for anything
else. The accent last seen for a context SHALL apply as soon as the context opens.

#### Scenario: A named theme

- **WHEN** the active tenant's theme is `ember`
- **THEN** primary buttons and links use ember's accent

#### Scenario: A custom accent

- **WHEN** the active tenant's theme is `#7a3ef0`
- **THEN** the accent is the colour tix derives from it for the current scheme

#### Scenario: The tenant cannot be read

- **WHEN** the credential may not read its tenant and no accent was seen before
- **THEN** the app uses tix's default teal

### Requirement: Meaning colours are not themeable

Status, priority and project colours SHALL be the same whatever accent the tenant names.

#### Scenario: A themed tenant

- **WHEN** the tenant's accent is plum
- **THEN** an in-progress status is still tix's teal, blocked still the warning colour and highest priority still red

### Requirement: Text and controls are readable

Text tokens SHALL reach 4.5:1 contrast on the page and the surface in both themes, and text on the accent SHALL
reach 4.5:1 for every built-in theme. Pressable things SHALL offer at least a 48 dp target, and screens SHALL not
clip at twice the text size.

#### Scenario: Forest

- **WHEN** the tenant uses the forest theme in light
- **THEN** its accent is darkened just enough that white text on it reaches 4.5:1

#### Scenario: Large text

- **WHEN** the system text size is 200%
- **THEN** task rows and page headers grow to fit without overflowing

### Requirement: A screen offers one create action

A screen that creates something SHALL offer it as one primary action with a plus icon and a label: a button in the
page header on wide windows, a labelled floating button on phones. Its form SHALL open as a bottom sheet on phones
and a dialog on wider windows. An empty list SHALL offer the same action.

#### Scenario: Quick add on a phone

- **WHEN** a person taps New task on a phone
- **THEN** the quick-add form opens in a bottom sheet

#### Scenario: Quick add on a desktop

- **WHEN** a person clicks New task on a 1280 pixel window
- **THEN** the quick-add form opens in a dialog

### Requirement: Destructive actions confirm

An action that cannot be undone SHALL be a red button that opens a confirmation whose confirm button is also red
and names the action.

#### Scenario: Signing out

- **WHEN** a person presses Sign out
- **THEN** a confirmation asks first, and nothing is forgotten until its red Sign out is pressed

### Requirement: Settings are never folded away

Settings SHALL be headed sections that are always drawn. Explanations SHALL be visible text or an (i) tip.

#### Scenario: Settings screen

- **WHEN** the settings screen opens
- **THEN** appearance, instances, account and about are all visible headed sections

### Requirement: Every state has a way forward and back

Lists SHALL show a skeleton while their first page loads, an explanation with a retry when it fails, and a message
when they are empty. An error on a pushed screen SHALL also offer a way back.

#### Scenario: Loading

- **WHEN** a list's first page is in flight
- **THEN** placeholder rows are shown and no spinner

#### Scenario: Failure

- **WHEN** loading a task fails on its own screen
- **THEN** the reason, a Retry button and a Back button are shown

### Requirement: The keyboard reaches every command

On any window the signed-in screens SHALL open a command palette on Ctrl+K or Cmd+K that lists the commands of the
screens on show and runs the chosen one, and SHALL list the keyboard shortcuts on `?`. Keys typed into a text field
SHALL stay in the field.

#### Scenario: Palette

- **WHEN** a person presses Ctrl+K and types "sett"
- **THEN** "Go to settings" is offered and Enter goes there

#### Scenario: Typing

- **WHEN** the quick-add field has focus and the person types `n`
- **THEN** the letter goes into the field and no command runs

### Requirement: The components can be seen together

Debug and profile builds SHALL offer a gallery of every component in light and dark and with a sample of tenant
accents. Release builds SHALL not route to it unless built with `TIX_GALLERY=true`.

#### Scenario: Debug build

- **WHEN** a developer opens Settings in a debug build
- **THEN** a Components entry opens the gallery
