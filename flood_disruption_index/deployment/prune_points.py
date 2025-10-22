import csv

# === CONFIG ===
INPUT_FILE = "simplified_routes_with_var.csv"
OUTPUT_FILE = "simplified_routes_pruned.csv"

# === 1. Read CSV ===
points = []
with open(INPUT_FILE, "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Keep row if Var is not 0
        if float(row["Var"]) != 0:
            points.append(row)

# === 2. Save pruned CSV ===
fieldnames = ["route_name", "distance_km", "duration_min", "lat", "lon", "order", "Var"]
with open(OUTPUT_FILE, "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(points)

print(f"✅ Pruned routes saved to {OUTPUT_FILE}")