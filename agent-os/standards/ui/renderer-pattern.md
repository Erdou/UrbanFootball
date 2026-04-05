---
name: Renderer Pattern
description: Stateless renderer classes for non-trivial drawing logic
type: standard
---

# Renderer Pattern

Extract drawing logic into stateless renderer classes when a view's rendering is non-trivial.

## Rules

- Renderers hold no state — all data passed as method params
- Views instantiate renderers in `initialize()` and hold references
- Views call renderer methods in `onUpdate()`, passing computed state
- Simple screens (few draw calls) can render directly in `onUpdate()`

## Example

```monkeyc
// Renderer: stateless, pure drawing
class MyScreenRenderer {
    function drawScreen(dc, width, height, score, timerText) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(width/2, 100, Graphics.FONT_LARGE, score.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }
}

// View: owns state, orchestrates rendering
class MyScreenView extends WatchUi.View {
    var _renderer;
    var score = 0;

    function initialize() {
        _renderer = new MyScreenRenderer();
    }

    function onUpdate(dc) {
        _renderer.drawScreen(dc, dc.getWidth(), dc.getHeight(), score, "00:00");
    }
}
```

## When to extract

- Multiple draw calls with positioning logic → extract
- 2-3 simple `drawText` calls → keep in `onUpdate()`
- Drawing shared across views → always extract
