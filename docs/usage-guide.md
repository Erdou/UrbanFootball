# Usage Guide

## Setup Flow

When you launch the app, two configuration screens appear before the main activity screen:

1. **Environment** — Choose **Outdoor** (GPS enabled) or **Indoor** (GPS off).
2. **Goalie Timer** — Choose **Yes** to enable or **No** to disable. If enabled, pick a duration (1–99 minutes, default 7).

Navigate these screens with the **UP/DOWN** buttons to move between options and **START** to confirm. You can also tap an option directly on the touchscreen.

---

## Main Activity Screen

### Starting & Stopping

| Action | How |
|---|---|
| Start recording | Press **START** (center button) |
| Pause recording | Press **START** again while recording |

On pause, a menu appears with three options: **Resume**, **Save**, or **Discard**. Use UP/DOWN to navigate and START to confirm, or tap an option.

### Scoring

There are two ways to change the score — **buttons** or **screen taps**. Both are only active while recording.

#### Button Controls

| Button | Short Press | Long Press |
|---|---|---|
| **UP** (left button) | +1 left score | Enter Score Adjust Mode (left side selected) |
| **DOWN** (right button) | +1 right score | — |

#### Touchscreen Taps

```
┌─────────────────────┐
│          │          │
│  Tap to  │  Tap to  │
│   +1     │   +1     │
│  LEFT    │  RIGHT   │
│          │          │
│──────────┴──────────│
│   Tap to reset      │
│   goalie timer      │
└─────────────────────┘
     bottom ~30%
```

- **Left half** of the screen — +1 left score.
- **Right half** of the screen — +1 right score.
- **Bottom ~30%** of the screen — Reset goalie timer (if enabled).

### Score Undo

After any score increase, a **3-second undo window** opens. The scored side is highlighted on screen. Tap that side (or press its button) again during the window to undo.

### Score Adjust Mode

For correcting scores downward:

1. **Long-press UP** to enter Score Adjust Mode (left side selected).
2. **Release UP** to toggle between left and right side.
3. **Press DOWN** to decrease the selected side by 1.
4. **Short-press BACK** or wait 5 seconds to exit.

---

## Goalie Timer

The goalie timer counts down from the configured duration while recording.

| Action | How |
|---|---|
| Reset timer | **Short-press BACK** or tap the **bottom of the screen** |
| Change timer settings | **Long-press BACK** (opens configuration) |

When the timer reaches zero it enters **overtime** and a **vibration pulse** repeats every ~1 second until you reset the timer or pause the activity.

---

## Button Reference

All five physical buttons on the watch:

| Button | Short Press | Long Press |
|---|---|---|
| **START** (center) | Start / pause recording | — |
| **UP** (top-left) | +1 left score | Enter Score Adjust Mode |
| **DOWN** (bottom-left) | +1 right score | — |
| **BACK** (bottom-right) | Reset goalie timer | Open goalie timer config |
| **BACK** in pause menu | Resume activity | — |

---

## Save & Discard

After pausing, the pause menu offers:

- **Resume** — Continue recording.
- **Save** — Save the activity session to Garmin. A confirmation screen appears; press START to confirm.
- **Discard** — Throw away the session. A confirmation screen appears; press START to confirm.

In both confirmation screens, press **DOWN** or **BACK** to go back to the pause menu instead.

---

## Tips

- Touchscreen input can be disabled in the app settings if you prefer buttons only.
- Button-triggered scores give a short vibration; screen taps do not.
- The goalie timer pauses automatically when the activity is paused and resumes when you continue.
- Maximum score per side is 99.
