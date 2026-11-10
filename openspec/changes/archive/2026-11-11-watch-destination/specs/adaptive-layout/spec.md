# adaptive-layout

## MODIFIED Requirements

### Requirement: The phone bar holds at most five destinations

Below 600 logical pixels wide the bottom bar SHALL show at most five destinations. When there are more, or the
bar carries a link such as About, it SHALL show the first four and More, which opens a sheet listing the rest and
then the links; the destination open from More SHALL mark More as selected. The rail SHALL show every destination.

#### Scenario: Six destinations

- **WHEN** the app has six destinations on a 400 pixel wide window
- **THEN** the bar shows four and More, and More lists the other two, then About

#### Scenario: The app's destinations

- **WHEN** a signed-in person opens the app on a 400 pixel wide window
- **THEN** the bar shows Projects, Tasks, My work, Inbox and More, and More lists Watch, Manage, Settings, then About
