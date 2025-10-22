import requests
import csv
import math
import os

# === CONFIG ===
MAPBOX_TOKEN = os.getenv("MAPBOX_API")
ORIGIN = (14.6571, 121.0645)  # UP Diliman
DESTINATION = (14.6407, 121.0770)  # Ateneo
OUTPUT_CSV = "mapbox_routes.csv"

def haversine(lat1, lon1, lat2, lon2):
    R = 6371000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return 2*R*math.atan2(math.sqrt(a), math.sqrt(1 - a))

def interpolate(p1, p2, step=100.0):
    lat1, lon1 = p1
    lat2, lon2 = p2
    dist = haversine(lat1, lon1, lat2, lon2)
    if dist == 0:
        return [p1]
    num_points = int(dist // step)
    return [
        (lat1 + (lat2 - lat1) * i / num_points,
         lon1 + (lon2 - lon1) * i / num_points)
        for i in range(num_points)
    ] + [p2]

def decode_polyline6(encoded):
    """Decodes a polyline6 (Mapbox) string to list of (lat, lon)."""
    result = []
    index = 0
    lat, lng = 0, 0
    shift, result_lat, result_lng = 0, 0, 0

    while index < len(encoded):
        b, shift, result_lat = 0, 0, 0
        while True:
            b = ord(encoded[index]) - 63
            index += 1
            result_lat |= (b & 0x1F) << shift
            shift += 5
            if b < 0x20:
                break
        lat += ~(result_lat >> 1) if result_lat & 1 else (result_lat >> 1)

        b, shift, result_lng = 0, 0, 0
        while True:
            b = ord(encoded[index]) - 63
            index += 1
            result_lng |= (b & 0x1F) << shift
            shift += 5
            if b < 0x20:
                break
        lng += ~(result_lng >> 1) if result_lng & 1 else (result_lng >> 1)

        result.append((lat / 1e6, lng / 1e6))
    return result

def fetch_routes():
    url = (
        f"https://api.mapbox.com/directions/v5/mapbox/driving-traffic/"
        f"{ORIGIN[1]},{ORIGIN[0]};{DESTINATION[1]},{DESTINATION[0]}"
        f"?alternatives=true&overview=full&geometries=polyline6&steps=false&access_token={MAPBOX_TOKEN}"
    )
    res = requests.get(url)
    data = res.json()

    if res.status_code != 200:
        print(f"Error: {res.status_code} - {data}")
        return []

    routes = []
    for i, r in enumerate(data["routes"]):
        decoded = decode_polyline6(r["geometry"])
        sampled = []
        for j in range(len(decoded) - 1):
            sampled.extend(interpolate(decoded[j], decoded[j+1], 100.0))

        route_name = r.get("summary", f"Route {i+1}")
        distance_km = r["distance"] / 1000
        duration_min = r["duration"] / 60
        routes.append({
            "name": route_name,
            "distance_km": distance_km,
            "duration_min": duration_min,
            "points": sampled
        })
    return routes

def save_to_csv(routes):
    with open(OUTPUT_CSV, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["route_name", "distance_km", "duration_min", "lat", "lon", "order"])
        for r in routes:
            for idx, (lat, lon) in enumerate(r["points"]):
                writer.writerow([r["name"], f"{r['distance_km']:.2f}", f"{r['duration_min']:.1f}", lat, lon, idx + 1])
    print(f"✅ Saved {len(routes)} routes to {OUTPUT_CSV}")

if __name__ == "__main__":
    routes = fetch_routes()
    save_to_csv(routes)
