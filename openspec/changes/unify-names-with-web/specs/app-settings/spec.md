# app-settings

## MODIFIED Requirements

### Requirement: Theme mode is chosen

Settings SHALL offer the colour scheme, named so, with the choices System, Light, Dark, OLED, Low contrast and "System, OLED when dark", in that order as on tix web, apply the choice at once and remember it across launches on this device. The default SHALL be System. "Theme" SHALL name only the tenant accent.

#### Scenario: Dark chosen

- **WHEN** a person picks Dark and restarts the app
- **THEN** the app is dark

#### Scenario: OLED black chosen

- **WHEN** a person picks OLED
- **THEN** the app is dark on a pure black page at once, and still is after a restart

#### Scenario: Low contrast chosen

- **WHEN** a person picks Low contrast
- **THEN** the app is drawn in tix web's dim palette, a `#1d2126` page with `#c7ccd3` text

## REMOVED Requirements

### Requirement: The system theme can go black

**Reason**: The switch is now a choice of its own, "System, OLED when dark", as on tix web.

**Migration**: Replaced by "System, OLED when dark follows the system on black". A stored switch reads as that
choice.

## ADDED Requirements

### Requirement: System, OLED when dark follows the system on black

The "System, OLED when dark" choice SHALL follow the platform's light and dark and draw the dark as OLED. It SHALL be stored as the system choice with the black flag the old switch used, so a device that had "Pure black when dark" on SHALL open on this choice.

#### Scenario: System dark goes black

- **WHEN** the choice is "System, OLED when dark" and the platform turns dark
- **THEN** the app is dark on a pure black page

#### Scenario: The old switch

- **WHEN** a device stored the system theme with "Pure black when dark" on, and the app starts after the update
- **THEN** Settings shows "System, OLED when dark" chosen

#### Scenario: Another choice clears it

- **WHEN** a person on "System, OLED when dark" picks System
- **THEN** the system's dark is tix's dark again, not black
