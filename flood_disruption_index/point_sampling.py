import os
import json
from shapely.geometry import shape, Point
from shapely.ops import nearest_points
from geopy.distance import geodesic

# --- CONFIG ---
CIRCLES_FILE = "processed_data/test_range.geojson"  # unified file with multiple circle features
GEOJSON_FILE = "noah_manila.geojson"
OUTPUT_FILE = "processed_data/sampled_points.json"

# --- STEP 1: LOAD VAR POLYGONS ---
with open(GEOJSON_FILE, "r") as f:
    geojson_data = json.load(f)

# Group polygons by Var
var_polygons = {}
for feat in geojson_data["features"]:
    var = feat["properties"].get("Var")
    if var is None:
        continue
    geom = shape(feat["geometry"])
    var_polygons.setdefault(var, []).append(geom)

print(f"Loaded {sum(len(v) for v in var_polygons.values())} polygons across {len(var_polygons)} Var zones.")

# --- STEP 2: LOAD CIRCLE FEATURES ---
with open(CIRCLES_FILE, "r") as f:
    circles_data = json.load(f)

circle_features = circles_data["features"]
print(f"Loaded {len(circle_features)} circle features from {CIRCLES_FILE}")

results = {}

# --- STEP 3: PROCESS EACH CIRCLE ---
for circle_feature in circle_features:
    circle_geom = shape(circle_feature["geometry"])
    props = circle_feature["properties"]

    point_id = props.get("Point_ID")
    radius_m = props.get("Radius_m")

    # center point
    center_coords = circle_geom.centroid
    center_lat, center_lon = center_coords.y, center_coords.x

    closest_per_var = []

    # --- Check each Var polygon group ---
    for var, polys in var_polygons.items():
        overlap_found = False
        min_distance = float("inf")
        closest_coord = None

        for poly in polys:
            if not poly.intersects(circle_geom):
                continue

            overlap_found = True
            # Find nearest point on the polygon to circle center
            p1, p2 = nearest_points(Point(center_lon, center_lat), poly)
            dist_m = geodesic((center_lat, center_lon), (p2.y, p2.x)).meters
            if dist_m < min_distance:
                min_distance = dist_m
                closest_coord = (p2.y, p2.x)

        if overlap_found and closest_coord:
            closest_per_var.append({
                "Var": var,
                "closest_lat": closest_coord[0],
                "closest_lon": closest_coord[1],
                "distance_m": round(min_distance, 3)
            })

    results[point_id] = {
        "center": {"lat": center_lat, "lon": center_lon},
        "radius_m": radius_m,
        "var_matches_count": len(closest_per_var),
        "closest_points": closest_per_var
    }

    print(f"{point_id}: {len(closest_per_var)} overlapping Var zones found.")

# --- STEP 4: SAVE RESULTS ---
with open(OUTPUT_FILE, "w") as f:
    json.dump(results, f, indent=2)

print(f"\n✅ Saved {len(results)} point results to {OUTPUT_FILE}")
