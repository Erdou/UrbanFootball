---
name: Responsive Layout
description: Two-tier layout with height < 280 breakpoint for small Garmin screens
type: standard
---

# Responsive Layout

Use conditional positioning methods to adapt layouts across screen sizes. Currently a two-tier system based on screen height. Breakpoint was tested on Fenix 7 Pro — may need adjustment when testing on other devices.

## Pattern

```monkeyc
function getTitleY(height) {
    if (height < 280) { return 20; }
    return 24;
}

function getFirstOptionY(height) {
    if (height < 280) { return 82; }
    return 94;
}

// In onUpdate:
function onUpdate(dc) {
    var height = dc.getHeight();
    dc.drawText(width/2, getTitleY(height), font, title, Graphics.TEXT_JUSTIFY_CENTER);
}
```

## Rules

- Use `height < 280` as the small-screen breakpoint (subject to revision after multi-device testing)
- Create named positioning methods (`getTitleY`, `getDividerY`, etc.) instead of inline conditionals
- Pass `height` (and `width` when needed) to positioning methods
- Keep both tiers' values close — small adjustments (4-12px), not wholesale redesigns

## Note

This breakpoint is based on Fenix 7 Pro testing only. When expanding device testing, additional breakpoints or a continuous scaling approach may be needed.
