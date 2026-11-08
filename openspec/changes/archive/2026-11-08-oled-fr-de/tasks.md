# Tasks

## 1. OLED black

- [x] 1.1 `TixTokens.oled`, `isBlack`, the accent tint mixed towards black
- [x] 1.2 `ThemeChoice`, the system black switch, `darkIsBlackProvider`, the dark theme built from them
- [x] 1.3 `TixChoices` with a gallery entry and goldens; Settings uses it for theme and language
- [x] 1.4 Gallery cycles light, dark and OLED black; goldens for every block in OLED black
- [x] 1.5 Contrast tests and the OLED contrast table in `docs/design.md`

## 2. French and German

- [x] 2.1 `app_fr.arb` and `app_de.arb` with every key
- [x] 2.2 The ARB guard test, watched failing
- [x] 2.3 Language picker lists Français and Deutsch; English is the fallback
- [x] 2.4 200% text tests in English, German and French; overflows fixed

## 3. About

- [x] 3.1 App info, engine and server version providers, `Diagnostics`
- [x] 3.2 About screen, route, Settings entry and palette command
- [x] 3.3 Tests, including a guard that diagnostics never carry a token
