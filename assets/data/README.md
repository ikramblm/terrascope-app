# TerraScope country dataset

`countries.json` is TerraScope's canonical, bundled country dataset — the
single source of truth for every game mode's country facts.

## The "195 countries" list

TerraScope defines "195 countries" as:

- the **193 UN member states**, plus
- the **2 UN General Assembly observer states**: the Holy See (`VAT`) and
  the State of Palestine (`PSE`).

This is the same definition most commercial geography games and reference
sources use. Countries flagged `unMember: false` and not one of the two
observer codes above are intentionally excluded (dependent territories,
partially-recognized states, etc.) — this keeps "Name All Countries" and
the 195-country counters unambiguous.

## Provenance

Generated from the [mledoze/countries](https://github.com/mledoze/countries)
open dataset (factual/geographic reference data — country names, ISO
codes, capitals, regions, borders, coordinates, area, currencies,
languages). Regenerate with:

```
python scripts/process_countries.py
```

(script kept alongside this file's source snapshot; re-run whenever the
upstream dataset is refreshed).

## Known gaps to backfill in a later phase

- `population` is `null` for every entry — the source dataset omits it
  deliberately (population changes too often for a static geographic
  dataset). Needs a maintained, versioned population source before the
  statistics/profile screens display it.
- `landmarks` and `emojiClues` are empty arrays — intentionally
  extensible fields, populated in the phases that build "Guess by
  Landmark" and "Guess by Emoji".
- `continent` is derived (Americas → North/South America by subregion;
  all other regions map 1:1 to continent). Transcontinental countries
  (e.g. Russia, Turkey, Kazakhstan) get the single continent the source
  dataset assigns them as their `region` — fine for continent-challenge
  categorization, but don't treat it as a claim that the country has no
  territory on the other continent.

## emoji_clues.json

A separate, hand-curated dataset (not from `countries.json`/mledoze) for
Guess by Emoji: `{ "cca3": ["emoji sequence", ...] }`. Covers ~90 widely
recognized countries as a Phase 2 MVP set — deliberately extensible
(multiple clue variants per country are supported, just add to the
array) rather than a fixed hardcoded question list. Guess by Emoji's
question generator only draws correct answers from countries present in
this file; wrong-answer options still draw from the full 195-country
pool. Expanding coverage to more countries is a content task, not a code
change — see `EmojiClueRepository`.
