---
name: Custom Icon Drawing
description: Draw icons with primitives (polygons, arcs, rects) for scalability and performance
type: standard
---

# Custom Icon Drawing

Draw icons using graphics primitives instead of bitmaps. Primitives scale across 42+ Garmin screen sizes without needing multiple bitmap resolutions, and are more performant.

## Preferred: Primitives

```monkeyc
// Play icon (triangle)
function drawPlayIcon(dc, x, y, size) {
    var half = size / 2;
    dc.fillPolygon([
        [x - (half / 2), y - half],
        [x + half, y],
        [x - (half / 2), y + half]
    ]);
}

// Check mark
function drawCheckMark(dc, cx, cy, size) {
    dc.setPenWidth(3);
    dc.drawLine(cx - size/2, cy, cx - size/6, cy + size/3);
    dc.drawLine(cx - size/6, cy + size/3, cx + size/2, cy - size/3);
}

// Save icon (arrow + tray)
function drawSaveIcon(dc, x, y, size) {
    var half = size / 2;
    dc.fillRectangle(x - 2, y - half, 4, size - 6);  // shaft
    dc.fillPolygon([...]);  // arrowhead
    dc.fillRectangle(x - (size/2 + 3), y + half + 2, size + 6, 3);  // tray
}
```

## When bitmaps are OK

- Complex detailed images (app launcher icon, photo-realistic assets)
- Icons loaded once at startup (`Rez.Drawables.*` in `initialize()`)

## Rules

- Position icons relative to center point `(x, y)` with `size` param for scalability
- Use `fillPolygon` for shapes, `drawArc` for curves, `fillRectangle` for boxes
- Keep icon functions in the View or Renderer that draws them
