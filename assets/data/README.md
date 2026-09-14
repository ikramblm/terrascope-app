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

## country_outlines.json

Real country boundary polygons for Guess by Outline:
`{ "cca3": [ [ [ [lon, lat], ... ], ...rings ], ...polygon parts ] }` —
each country is a list of polygon parts (mainland plus any islands/
exclaves), each part a list of rings (ring 0 exterior, further rings
holes), each ring a list of `[lon, lat]` points rounded to 3 decimal
places (~111m precision).

**Provenance:** converted from the public-domain
[Natural Earth](https://www.naturalearthdata.com/) 1:110m admin-0
countries dataset, via the
[world-atlas](https://github.com/topojson/world-atlas) `countries-110m.json`
TopoJSON build (`cdn.jsdelivr.net/npm/world-atlas@2/countries-110m.json`),
decoded and matched to our `cca3` codes by
`scripts/convert_country_outlines.py`.

**Coverage:** 166 of the 195 countries. The 110m resolution is too coarse
to render very small nations at all (Vatican City, Monaco, Malta,
Singapore, Liechtenstein, San Marino, and every Pacific/Caribbean
microstate are the main gaps) — same "curated, extensible subset"
pattern as `emoji_clues.json`. Guess by Outline's question generator only
draws correct answers from countries present in this file; wrong-answer
options still draw from the full 195-country pool. A higher-resolution
source dataset (e.g. Natural Earth's 50m or 10m tables) would close most
of the gap, at the cost of a larger bundled file — a content task, not a
code change, if it's ever worth doing.
