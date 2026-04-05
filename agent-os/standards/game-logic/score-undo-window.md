---
name: Score Undo Window
description: 3-second temporal undo after score increment, side-locked to prevent wrong-team undo
type: standard
---

# Score Undo Window

After a score increment, a 3-second undo window opens on that side only. Re-tapping the same side undoes the increment. Side-locking prevents accidentally undoing the wrong team's score.

## Rules

- Window opens only on increment (delta > 0), not on decrement
- Only the scored side can be undone; other side behaves normally
- If score was clamped (at 0 or 99 boundary), no window opens
- Window auto-expires after 3 seconds
- Entering score adjust mode clears any active undo window

## Flow

```
Tap left → scoreA++ → undo window opens (left, 3s)
  ├─ Re-tap left within 3s → scoreA-- (undo) → window closes
  ├─ Tap right within 3s → scoreB++ → new undo window (right, 3s)
  └─ 3s expires → window closes, next left tap increments again
```

## Implementation

```monkeyc
const SCORE_UNDO_WINDOW_MS = 3000;
var _scoreUndoSide = null;  // true=left, false=right
var _scoreUndoExpiresAt = null;

function adjustScore(isLeft, delta, withVibration) {
    if (isScoreUndoWindowActive() && isLeft == _scoreUndoSide && delta > 0) {
        // Undo: decrement instead of increment
        applyScoreDelta(isLeft, -1);
        clearScoreUndoWindow();
        return;
    }
    applyScoreDelta(isLeft, delta);
    if (updatedScore != previousScore && delta > 0) {
        startScoreUndoWindow(isLeft);
    }
}
```
