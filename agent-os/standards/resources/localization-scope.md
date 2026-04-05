---
name: Localization Scope
description: Only strings are localized (35 langs); layouts, menus, drawables are universal
type: standard
---

# Localization Scope

Only string resources are localized. Layouts, menus, and drawables are language-independent. RTL text direction for Arabic/Hebrew is handled by the Garmin SDK.

## What to localize

| Resource type | Localized? | Location |
|--------------|-----------|----------|
| Strings | Yes (35 langs) | `resources-{lang}/strings/strings.xml` |
| Layouts | No | `resources/layouts/layout.xml` |
| Menus | No | `resources/menus/menu.xml` |
| Drawables | No | `resources/drawables/` |

## Localization rules

- All string IDs must be present in all 35 locale files (complete parity)
- Format strings include locale-specific punctuation (French " : " vs English ": ")
- Abbreviations are localized (Arabic "د" vs English "min")
- App branding ("UrbanFootball") stays in English across all locales
- `%1$s` positional placeholders are preserved in all translations

## Adding a new string

1. Add to `resources/strings/strings.xml` (English default)
2. Add translation to all 35 `resources-{lang}/strings/strings.xml` files
3. Use the `{feature}{Element}{Suffix}` naming convention

## Adding a new locale

1. Create `resources-{code}/strings/strings.xml`
2. Copy all string IDs from the English file
3. Add the language code to `manifest.xml` `<iq:languages>` block
