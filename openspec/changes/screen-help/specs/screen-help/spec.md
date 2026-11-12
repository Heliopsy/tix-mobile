## ADDED Requirements

### Requirement: Every screen links to its documentation

Every routed screen drawn as a page SHALL show a (?) button in its header that opens the tix documentation section
about that screen in the browser, unless no tix documentation covers the screen. The button SHALL be a 48 dp target
with a screen reader label naming the screen, and SHALL appear once per screen even when a page is drawn inside
another.

#### Scenario: A screen with a documented section

- **WHEN** someone opens the trash
- **THEN** its header shows a (?) labelled "Help: Trash", and pressing it opens the section on the trash

#### Scenario: An app-only screen

- **WHEN** someone opens the sync conflicts screen, which tix's documentation does not describe
- **THEN** its header shows no (?) button

#### Scenario: A list with its detail beside it

- **WHEN** a wide window shows a task beside its list
- **THEN** one (?) button is shown, the one for that route

### Requirement: Help opens the docs of the release in use

The help link SHALL go through the connected server's public documentation redirect,
`<server address>/docs/<page>?section=<anchor>`, keeping any path the address has, so the reader lands on the docs
of the release that server runs. With no remote server, it SHALL open the docs on GitHub at the embedded engine's
release tag, or at `main` when the engine has no release version.

#### Scenario: A server under a path

- **WHEN** the active server's address is `https://example.com/tix/`
- **THEN** help for the trash opens `https://example.com/tix/docs/tenancy.md?section=the-trash`

#### Scenario: A local instance

- **WHEN** the active instance is on this device and its engine is tix 0.57.0
- **THEN** help opens `https://github.com/heliopsy/tix/blob/v0.57.0/docs/<page>#<anchor>`

### Requirement: Every help link names a real heading

Every routed screen SHALL have an entry in the help map, naming a page and heading or stating that it has none. Every
named heading SHALL exist in tix's documentation at the commit `tix.lock` pins.

#### Scenario: A new route without an entry

- **WHEN** a screen is routed without a help entry
- **THEN** the help map test fails and names the route

#### Scenario: A heading renamed in tix

- **WHEN** `tix.lock` moves to a tix whose docs no longer have a mapped heading
- **THEN** the anchors test fails until the map or the vendored anchors are updated
