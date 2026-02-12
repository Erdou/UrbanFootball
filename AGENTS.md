# Repository Guidelines

## Project Structure & Module Organization
- `source/`: Monkey C app logic. Files follow `UrbanFootball<Feature><Role>.mc` (for example, `UrbanFootballActivityView.mc`, `UrbanFootballGoalieModeDelegate.mc`).
- `resources/`: Connect IQ assets in `drawables/`, `layouts/`, `menus/`, and `strings/`.
- `manifest.xml`: app id, supported products, permissions, and language settings.
- `monkey.jungle`: project entry used by the Monkey C compiler.
- `bin/` and `build/`: generated artifacts (`.prg`, debug XML, MIR). Treat as build output; do not edit manually.

## Build, Test, and Development Commands
Set your SDK path once:
```bash
export CIQ_SDK="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-<version>"
```
Compile and launch in simulator:
```bash
java -jar "$CIQ_SDK/bin/monkeybrains.jar" \
  -o bin/UrbanFootball.prg -f monkey.jungle -y <path-to-dev-key> \
  -d fenix7pro_sim -w
```
Optional run command (if `monkeydo` is available):
```bash
monkeydo bin/UrbanFootball.prg fenix7pro
```
Clean generated output:
```bash
rm -rf bin build
```

## Coding Style & Naming Conventions
- Use 4-space indentation and keep braces on the same line as declarations.
- Use PascalCase class names with the `UrbanFootball` prefix.
- Use descriptive role suffixes: `View`, `Delegate`, `Renderer`, `App`.
- Constants use `UPPER_SNAKE_CASE`; fields and methods use camelCase.
- Keep methods focused; isolate timer, navigation, and rendering responsibilities.

## Testing Guidelines
- No automated test suite is currently configured; validate changes in Connect IQ Simulator before opening a PR.
- Minimum manual checks: environment selection, goalie mode and duration setup, pre-start-to-live transition, score controls, overtime vibration pulse, and back-navigation reset behavior.
- Test at least one supported target from `manifest.xml` (default: `fenix7pro`).

## Commit & Pull Request Guidelines
- Match existing history: imperative, behavior-focused commit subjects (for example, `Add dedicated pre-start screen`, `Refactor goalie duration controls`).
- Keep each commit scoped to one logical change.
- PRs should include a concise summary, simulator/device used, screenshots for UI changes, and linked issue/task when available.

## Security & Configuration Tips
- Never commit developer keys or machine-specific absolute paths.
- Keep SDK and key locations in local environment variables rather than source files.
