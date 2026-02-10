# Repository Guidelines

## Project Structure & Module Organization
- `source/` contains Monkey C application logic:
  - `FootballAppApp.mc`: app entry point and initial view wiring.
  - `FootballAppDelegate.mc`: input handling, session start/stop, and key behavior.
  - `FootballAppView.mc`: rendering, timer updates, and activity data display.
- `resources/` contains UI assets and localization files:
  - `layouts/`, `menus/`, `strings/`, `drawables/`.
- Root config files:
  - `manifest.xml` (products, permissions, app metadata).
  - `monkey.jungle` (project manifest mapping).
- `bin/`, `build/`, `gen/`, `*.prg`, and `*.prg.debug.xml` are generated artifacts; do not edit them manually.

## Build, Test, and Development Commands
- Build a PRG (example device target):
  - ``$CIQ_SDK_HOME/bin/monkeyc -f monkey.jungle -m manifest.xml -d fenix7 -o build/FootballApp.prg``
- Run in simulator:
  - ``$CIQ_SDK_HOME/bin/monkeydo build/FootballApp.prg fenix7``
- VS Code alternative: use Monkey C extension commands such as `Monkey C: Build for Device` and `Monkey C: Run App`.

## Coding Style & Naming Conventions
- Use 4-space indentation and K&R-style braces (`function foo() {`).
- Keep class names and file names aligned in PascalCase (`FootballAppView` in `FootballAppView.mc`).
- Use lowerCamelCase for methods/variables (`goalieTimerStart`, `getInitialView`); reserve leading `_` for internal fields (`_view`).
- Add user-facing text in `resources/strings/strings.xml` when introducing new labels.

## Testing Guidelines
- There is currently no automated test suite; validate behavior in Connect IQ simulator before opening a PR.
- Minimum manual checks:
  - Left/right tap increments score.
  - Bottom tap resets goalie timer and triggers vibration (when supported).
  - `START/ENTER` toggles recording state indicator.
  - `ESC` stops/saves session safely.

## Commit & Pull Request Guidelines
- Follow the existing commit style from history: imperative, capitalized summaries (for example, `Refactor FootballAppView rendering`).
- Prefer one logical change per commit.
- PRs should include:
  - concise change summary,
  - test notes (simulator/device and what was validated),
  - screenshots for UI updates,
  - explicit note for any new permission added to `manifest.xml`.
