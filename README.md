# Urban Football - Connect IQ Watch App

![Garmin Connect IQ](https://img.shields.io/badge/Garmin_ConnectIQ-3.4%2B-0A64A4?style=for-the-badge&logo=garmin&logoColor=white)
![Monkey C](https://img.shields.io/badge/Monkey_C-Watch_App-FF8C00?style=for-the-badge)
![Garmin Wearables](https://img.shields.io/badge/Platform-Garmin_Wearables-2E7D32?style=for-the-badge)
![Simulator](https://img.shields.io/badge/Tested-ConnectIQ_Simulator-0057B8?style=for-the-badge)
![Sport](https://img.shields.io/badge/Sport-Football%2FSoccer-1B5E20?style=for-the-badge)

Urban Football is a Garmin Connect IQ watch app for football sessions. It combines match tracking (score + game timer), activity recording, and a configurable goalie timer with overtime vibration alerts.

## Technical Stack
- Monkey C (Toybox APIs)
- Garmin Connect IQ SDK (`monkeybrains.jar`, optional `monkeydo`)
- Garmin wearable targets defined in `manifest.xml` (min API level `3.4.0`)

## Features
- Indoor/Outdoor mode selection before session start
- GPS mode toggle based on selected environment
- Live score tracking for both teams
- Game timer display tied to recording state
- Goalie timer: enable/disable, custom duration (1-99 min), quick reset
- Overtime pulse vibration alerts when goalie time is exceeded
- Pre-start screen and start transition overlay

## Quick Start
1. Install prerequisites: Java, Garmin Connect IQ SDK, developer key.
2. Set SDK path:
   ```bash
   export CIQ_SDK="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-<version>"
   ```
3. Build and run in simulator:
   ```bash
   java -jar "$CIQ_SDK/bin/monkeybrains.jar" \
     -o bin/UrbanFootball.prg -f monkey.jungle -y <path-to-dev-key> \
     -d fenix7pro_sim -w
   ```
4. Optional simulator run command:
   ```bash
   monkeydo bin/UrbanFootball.prg fenix7pro
   ```

## Controls
- Tap left/right half: increment left/right score (after activity start)
- `UP` short press: +1 left score
- `UP` long press: -1 left score
- `DOWN` short press: +1 right score
- `DOWN` long press: -1 right score
- `START` or `ENTER`: start/stop activity recording
- `ESC` short press: reset goalie timer
- `ESC` long press: open goalie timer configuration

## Project Structure
- `source/`: app logic (`UrbanFootballApp`, views, delegates, renderers)
- `resources/`: strings, layouts, menus, and drawables
- `manifest.xml`: app metadata, products, permissions
- `monkey.jungle`: project manifest reference
- `bin/`, `build/`: generated artifacts

## Development Notes
- Do not edit generated outputs in `bin/` or `build/`.
- Keep naming consistent with existing files: `UrbanFootball<Feature><Role>.mc`.
- Validate behavior in Connect IQ Simulator before opening a PR.

## Contribution Workflow
- Use focused, imperative commit messages (for example, `Add pre-start transition overlay`).
- Include simulator/device and manual test notes in pull requests.
- Add screenshots when changing visuals or interaction flows.
