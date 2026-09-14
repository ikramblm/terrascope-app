"""Converts world-atlas's countries-110m.json (TopoJSON, public-domain
Natural Earth 110m admin-0 boundaries) into TerraScope's
assets/data/country_outlines.json — see that file's README section for
the output format and coverage notes.

Source: https://cdn.jsdelivr.net/npm/world-atlas@2/countries-110m.json
Regenerate with: python scripts/convert_country_outlines.py
"""

import json
import os

TOPO_SRC = r"C:\Users\LENOVO\Downloads\countries-110m.json"
COUNTRIES_PATH = r"C:\Users\LENOVO\Downloads\terrascope-app\assets\data\countries.json"
OUT_PATH = r"C:\Users\LENOVO\Downloads\terrascope-app\assets\data\country_outlines.json"

# Territories / non-UN-member entities present in the 110m dataset that
# have no match in our 195-country cca3 list — deliberately excluded.
EXCLUDED_NE_NAMES = {
    "Antarctica", "Falkland Is.", "Fr. S. Antarctic Lands", "Greenland",
    "New Caledonia", "Puerto Rico", "N. Cyprus", "Somaliland",
    "W. Sahara", "Kosovo", "Taiwan",
}

# Natural Earth name -> our dataset's nameCommon, wherever they differ.
NAME_OVERRIDES = {
    "Bosnia and Herz.": "Bosnia and Herzegovina",
    "C\u00f4te d'Ivoire": "Ivory Coast",
    "Macedonia": "North Macedonia",
    "Dem. Rep. Congo": "DR Congo",
    "Central African Rep.": "Central African Republic",
    "Dominican Rep.": "Dominican Republic",
    "eSwatini": "Eswatini",
    "United States of America": "United States",
    "S. Sudan": "South Sudan",
    "Eq. Guinea": "Equatorial Guinea",
    "Solomon Is.": "Solomon Islands",
    "Turkey": "T\u00fcrkiye",
}


def decode_arcs(topo):
    scale = topo["transform"]["scale"]
    translate = topo["transform"]["translate"]
    decoded = []
    for arc in topo["arcs"]:
        points = []
        x = y = 0
        for dx, dy in arc:
            x += dx
            y += dy
            points.append([x * scale[0] + translate[0], y * scale[1] + translate[1]])
        decoded.append(points)
    return decoded


def resolve_ring(arc_indices, arcs):
    """TopoJSON ring: concatenate arcs (negative index = reversed arc,
    via bitwise complement), dropping each arc's first point after the
    first (it duplicates the previous arc's last point)."""
    ring = []
    for idx in arc_indices:
        pts = arcs[idx] if idx >= 0 else list(reversed(arcs[~idx]))
        ring.extend(pts[1:] if ring else pts)
    return ring


def geometry_to_polygons(geom, arcs):
    """List of polygon parts; each part a list of rings (ring 0 = exterior)."""
    if geom["type"] == "Polygon":
        return [[resolve_ring(ring, arcs) for ring in geom["arcs"]]]
    if geom["type"] == "MultiPolygon":
        return [[resolve_ring(ring, arcs) for ring in poly] for poly in geom["arcs"]]
    raise ValueError(geom["type"])


def main():
    topo = json.load(open(TOPO_SRC, encoding="utf-8"))
    arcs = decode_arcs(topo)
    geometries = topo["objects"]["countries"]["geometries"]

    our_countries = json.load(open(COUNTRIES_PATH, encoding="utf-8"))
    by_name = {c["nameCommon"]: c["cca3"] for c in our_countries}

    matched = {}
    unmatched = []
    for geom in geometries:
        ne_name = geom["properties"]["name"]
        if ne_name in EXCLUDED_NE_NAMES:
            continue
        our_name = NAME_OVERRIDES.get(ne_name, ne_name)
        cca3 = by_name.get(our_name)
        if cca3 is None:
            unmatched.append(ne_name)
            continue
        polygons = geometry_to_polygons(geom, arcs)
        # Round to 3 decimal places (~111m precision) to keep the file small.
        rounded = [
            [[[round(x, 3), round(y, 3)] for x, y in ring] for ring in poly]
            for poly in polygons
        ]
        matched[cca3] = rounded

    if unmatched:
        print(f"WARNING - unmatched Natural Earth names (not in our 195): {unmatched}")

    json.dump(matched, open(OUT_PATH, "w", encoding="utf-8"), separators=(",", ":"))
    print(f"Matched {len(matched)}/{ {c['cca3'] for c in our_countries}.__len__() } countries")
    print(f"Wrote {OUT_PATH} ({os.path.getsize(OUT_PATH)} bytes)")


if __name__ == "__main__":
    main()
