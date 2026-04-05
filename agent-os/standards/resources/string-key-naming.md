---
name: String Key Naming
description: Context-prefixed string IDs with semantic suffixes for discoverability
type: standard
---

# String Key Naming

String resource IDs use a `{feature}{Element}{Suffix}` pattern. Emerged organically but now followed consistently.

## Format

`{feature}{Element}{Suffix}`

- **Feature prefix:** screen or feature name (`goalie`, `pause`, `environment`, `gameTime`)
- **Element:** specific UI element (`Mode`, `Duration`, `Menu`, `Save`)
- **Suffix:** role of the string

## Suffix conventions

| Suffix | Use | Example |
|--------|-----|--------|
| `Title` | Screen/section headings | `goalieModeTitle`, `pauseSaveConfirmTitle` |
| `Label` | Static labels | `gameTimeLabel` |
| `Format` | Template with `%1$s` placeholders | `gameTimeFormat`, `goalieTimeFormat` |
| `Prefix` | Text prepended to a value | `goalieTimePrefix` |
| `Suffix` | Text appended to a value | `goalieDurationValueSuffix` |
| `Hint` | Instructional text | `goalieDurationHint` |
| (none) | Action labels or simple values | `pauseMenuSave`, `environmentIndoor` |

## Examples

```xml
<string id="goalieDurationTitle">Goalie Timer</string>
<string id="goalieDurationValueFormat">%1$s</string>
<string id="goalieDurationValueSuffix">min</string>
<string id="goalieDurationHint">1 to 99 minutes</string>
```

## Rules

- Always prefix with feature name for grouping and discoverability
- Use camelCase (not snake_case or kebab-case)
- Format strings use Java-style positional placeholders (`%1$s`)
- App branding (`AppName`) is the only exception to the prefix rule
