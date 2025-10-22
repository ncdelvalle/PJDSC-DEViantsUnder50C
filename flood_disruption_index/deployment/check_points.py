import csv
import json
from shapely.geometry import shape, Point

# === CONFIG ===
SIMPLIFIED_ROUTES_FILE = "simplified_routes.csv"
OUTPUT_FILE = "simplified_routes_with_var.csv"
GEOJSON_FILE = "../raw_data/ncr_noah.geojson"

# === 1. Load GeoJSON ===
with open(GEOJSON_FILE, "r") as f:
    geojson_data = json.load(f)

def get_highest_var(lon, lat, geojson_data):
    """Return the highest Var value for the point in any intersecting polygon."""
    point = Point(lon, lat)
    highest_var = None

    for feature in geojson_data["features"]:
        polygon = shape(feature["geometry"])
        if polygon.intersects(point):
            var_value = feature["properties"].get("Var", None)
            if var_value is not None:
                if highest_var is None or var_value > highest_var:
                    highest_var = var_value
    return highest_var if highest_var is not None else 0  # fallback 0

# === 2. Read simplified routes CSV ===
points = []
with open(SIMPLIFIED_ROUTES_FILE, "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        points.append({
            "route_name": row["route_name"],
            "distance_km": row["distance_km"],
            "duration_min": row["duration_min"],
            "lat": float(row["lat"]),
            "lon": float(row["lon"]),
            "order": row["order"]
        })

# === 3. Assign Var to each point ===
for p in points:
    print(p)
    p["Var"] = get_highest_var(p["lon"], p["lat"], geojson_data)

# === 4. Save new CSV with Var column ===
fieldnames = ["route_name", "distance_km", "duration_min", "lat", "lon", "order", "Var"]
with open(OUTPUT_FILE, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(points)

print(f"\n✅ Simplified routes with Var saved to {OUTPUT_FILE}")
