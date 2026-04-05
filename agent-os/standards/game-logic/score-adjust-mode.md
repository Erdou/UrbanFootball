---
name: Score Adjust Mode
description: Long-press-activated decrement mode for score correction without touchscreen
type: standard
---

# Score Adjust Mode

A modal decrement mode activated by long-press, designed so score corrections work without touchscreen (limited physical buttons). Auto-expires after 5 seconds of inactivity, refreshing on each adjustment for batch corrections.

## Rules

- Long-press UP (≥550ms) enters adjust mode targeting left side
- UP release in adjust mode switches sides (left ↔ right)
- DOWN release in adjust mode decrements the selected side
- Each adjustment refreshes the 5-second timeout
- Entering adjust mode clears any active undo window (mutually exclusive)
- Back button or timeout exits adjust mode

## State transitions

```
Normal mode
  └─ Long-press UP → Adjust mode (left selected)
       ├─ UP tap → switch to right side (timeout refreshed)
       ├─ DOWN tap → decrement selected side (timeout refreshed)
       ├─ 5s inactivity → exit to normal mode
       └─ Back button → exit to normal mode
```

## Implementation

```monkeyc
const SCORE_ADJUST_MODE_TIMEOUT_MS = 5000;
var _scoreAdjustModeSide = null;  // true=left, false=right, null=inactive
var _scoreAdjustModeExpiresAt = null;

function enterScoreAdjustMode(isLeft) {
    clearScoreUndoWindow();  // Mutually exclusive
    _scoreAdjustModeSide = isLeft;
    _scoreAdjustModeExpiresAt = System.getTimer() + SCORE_ADJUST_MODE_TIMEOUT_MS;
    _scoreAdjustModeTimer.start(method(:onScoreAdjustModeEndTick),
        SCORE_ADJUST_MODE_TIMEOUT_MS + 30, false);
}

function refreshScoreAdjustModeTimeout() {
    _scoreAdjustModeExpiresAt = System.getTimer() + SCORE_ADJUST_MODE_TIMEOUT_MS;
    _scoreAdjustModeTimer.stop();
    _scoreAdjustModeTimer.start(method(:onScoreAdjustModeEndTick),
        SCORE_ADJUST_MODE_TIMEOUT_MS + 30, false);
}
```
