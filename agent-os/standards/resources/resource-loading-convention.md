---
name: Resource Loading Convention
description: Load all resources once in initialize(), cache as instance vars
type: standard
---

# Resource Loading Convention

Load all string and drawable resources in `initialize()`, store as instance variables. Avoids repeated disk reads (performance) and ensures the same locale is used throughout the session (consistency).

## Pattern

```monkeyc
class MyView extends WatchUi.View {
    var _title;
    var _icon;

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.myTitle);
        _icon = WatchUi.loadResource(Rez.Drawables.MyIcon);
    }

    function onUpdate(dc) {
        // Use cached values, never call loadResource here
        dc.drawText(x, y, font, _title, justify);
    }
}
```

## Rules

- Load in `initialize()`, never in `onUpdate()` or `onShow()`
- Store as instance vars with underscore prefix (`_title`, `_icon`)
- Cast drawables: `WatchUi.loadResource(Rez.Drawables.X) as Graphics.BitmapType`
- Use null-coalescing for defensive fallbacks: `_label ?? "fallback"`
- No dynamic resource reloading during activity lifecycle
