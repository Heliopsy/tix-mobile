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
- **THEN** the bar shows Inbox, My work, Tasks, Projects and More, and More lists Activity, Manage, Settings, then About

## ADDED Requirements

### Requirement: Destinations follow tix web's order

The destinations SHALL be, in this order on the rail and the phone bar: Inbox, My work, Tasks, Projects, Activity, Manage, Settings, the order tix web's sidebar uses. Each destination SHALL be found by its id, never by its position, so a reorder changes no stored choice.

#### Scenario: The rail

- **WHEN** a signed-in person opens the app on a 1280 pixel wide window
- **THEN** the rail reads Inbox, My work, Tasks, Projects, Activity, Manage, Settings, and tapping each opens its screen
