import csv
import math
import requests
import polyline
import os

# === CONFIG ===
MAPBOX_TOKEN = os.getenv("MAPBOX_API")
ORIGIN = (14.65728, 121.064451)   # UP
DESTINATION = (14.640998, 121.077131)  # ATENEO
OUTPUT_FILE = "simplified_routes.csv"

def haversine(lat1, lon1, lat2, lon2):
    """Calculate distance in meters between two lat/lon points."""
    R = 6371000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

def simplify_points(points, target_count=50):
    """Reduce points evenly along the route."""
    if len(points) <= target_count:
        return points
    step = len(points) // target_count
    return [points[i] for i in range(0, len(points), step)]

def clean_name(name):
    """Return None if road is unnamed or blank."""
    if not name or name.lower().startswith("unnamed"):
        return None
    return name.strip()

def get_route_names(routes):
    """
    For each route, find the first step that differs from the first route.
    If the step is unnamed, continue along the steps until a named road is found.
    If still unnamed by the end, fallback to Alternate Route N.
    """
    base_steps = [clean_name(s.get("name")) for s in routes[0].get("legs", [])[0].get("steps", [])]

    route_names = []
    for i, route in enumerate(routes):
        steps = [clean_name(s.get("name")) for s in route.get("legs", [])[0].get("steps", [])]

        # Find first differing index
        diff_name = None
        for j, name in enumerate(steps):
            base_name = base_steps[j] if j < len(base_steps) else None
            if name != base_name:
                # Divergence found
                if name:
                    diff_name = name
                    break
                else:
                    # Continue searching for first non-blank name
                    for k in range(j+1, len(steps)):
                        if steps[k]:
                            diff_name = steps[k]
                            break
                    break

        if not diff_name:
            diff_name = f"Alternate Route {i+1}"

        route_names.append(diff_name)

    return route_names

# === 1. Request Mapbox routes ===
url = f"https://api.mapbox.com/directions/v5/mapbox/driving/{ORIGIN[1]},{ORIGIN[0]};{DESTINATION[1]},{DESTINATION[0]}"
params = {
    "alternatives": "true",
    "overview": "full",
    "geometries": "polyline6",
    "steps": "true",
    "access_token": MAPBOX_TOKEN,
}
resp = requests.get(url, params=params)
data = resp.json()

routes = data.get("routes", [])
if not routes:
    raise ValueError("❌ No routes found in Mapbox response")

# === 2. Determine route names ===
route_names = get_route_names(routes)

# === 3. Write to CSV ===
with open(OUTPUT_FILE, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["route_name", "distance_km", "duration_min", "lat", "lon", "order"])

    for route, route_name in zip(routes, route_names):
        distance_km = route["distance"] / 1000
        duration_min = route["duration"] / 60
        coords = polyline.decode(route["geometry"], precision=6)
        simplified = simplify_points(coords, target_count=50)

        for order, (lat, lon) in enumerate(simplified, start=1):
            writer.writerow([f"via {route_name}", round(distance_km, 2), round(duration_min, 1), lat, lon, order])

print(f"✅ Saved simplified routes to {OUTPUT_FILE}")
