import json

SRC = r"C:\Users\LENOVO\Downloads\countries.json"
OUT = r"C:\Users\LENOVO\Downloads\terrascope-app\assets\data\countries.json"

with open(SRC, "r", encoding="utf-8") as f:
    data = json.load(f)

# TerraScope's defined "195 countries" list: 193 UN member states + 2 UN
# General Assembly observer states (Holy See, State of Palestine).
OBSERVER_CCA3 = {"VAT", "PSE"}

CONTINENT_OVERRIDES = {
    # cca3 -> continent, for cases the region/subregion split can't resolve
}

def continent_for(entry):
    region = entry.get("region", "")
    subregion = entry.get("subregion", "")
    if region == "Americas":
        if subregion == "South America":
            return "South America"
        return "North America"  # North America, Central America, Caribbean
    if region in ("Africa", "Asia", "Europe", "Oceania"):
        return region
    return region or "Other"

result = []
skipped = []
for e in data:
    cca3 = e.get("cca3")
    is_un = bool(e.get("unMember"))
    is_observer = cca3 in OBSERVER_CCA3
    if not (is_un or is_observer):
        continue

    name = e.get("name", {})
    capital = e.get("capital") or []
    latlng = e.get("latlng") or [None, None]
    currencies = e.get("currencies") or {}
    languages = e.get("languages") or {}

    result.append({
        "cca2": e.get("cca2"),
        "cca3": cca3,
        "nameCommon": name.get("common"),
        "nameOfficial": name.get("official"),
        "capital": capital[0] if capital else None,
        "region": e.get("region"),
        "subregion": e.get("subregion"),
        "continent": continent_for(e),
        "latitude": latlng[0],
        "longitude": latlng[1],
        "area": e.get("area"),
        "population": None,  # not present in source dataset; backfill later
        "flagEmoji": e.get("flag"),
        "currencies": [
            {"code": code, "name": c.get("name"), "symbol": c.get("symbol")}
            for code, c in currencies.items()
        ],
        "languages": list(languages.values()),
        "borders": e.get("borders") or [],
        "landlocked": bool(e.get("landlocked", False)),
        "independent": bool(e.get("independent", False)),
        "unMember": is_un,
        "altSpellings": e.get("altSpellings") or [],
        "landmarks": [],   # extensible: filled in later phase
        "emojiClues": [],  # extensible: filled in later phase
    })

result.sort(key=lambda c: c["nameCommon"] or "")

import os
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, indent=2)

print(f"Wrote {len(result)} countries to {OUT}")

# sanity checks
by_cca3 = {c["cca3"] for c in result}
missing_observers = OBSERVER_CCA3 - by_cca3
if missing_observers:
    print("WARNING missing observer states:", missing_observers)

no_capital = [c["nameCommon"] for c in result if not c["capital"]]
if no_capital:
    print("No capital listed for:", no_capital)
