import json
import pandas as pd
import random

# === 1. Load JSON file ===
with open("processed_data/sample_points.json", "r") as f:
    data = json.load(f)

# === 2. Prepare containers ===
centers = []
var_points = {1: [], 2: [], 3: []}

# === 3. Extract coordinates from JSON ===
for pid, info in data.items():
    # Center coordinate (Var 0)
    centers.append({
        "Point_ID": pid,
        "Latitude": info["center"]["lat"],
        "Longitude": info["center"]["lon"],
        "Var": 0
    })
    
    # Hazard-level coordinates (Var 1–3)
    for cp in info["closest_points"]:
        var = int(cp["Var"])
        var_points[var].append({
            "Point_ID": pid,
            "Latitude": cp["closest_lat"],
            "Longitude": cp["closest_lon"],
            "Var": var
        })

# === 4. Sampling setup ===
random.seed(42)
used_ids = set()

def sample_unique(pool, n, label):
    """Sample unique Point_IDs from a pool."""
    available = [p for p in pool if p["Point_ID"] not in used_ids]
    chosen = random.sample(available, min(n, len(available)))
    used_ids.update([p["Point_ID"] for p in chosen])
    print(f"✅ Selected {len(chosen)} {label} points (unique Point_IDs)")
    return chosen

# === 5. Sample progressively by hazard level (Var 3 → Var 2 → Var 1 → centers) ===
selected_var3 = sample_unique(var_points[3], 40, "Var 3")
selected_var2 = sample_unique(var_points[2], 60, "Var 2")
selected_var1 = sample_unique(var_points[1], 34, "Var 1")
selected_centers = sample_unique(centers, 66, "Center")

# === 6. Combine all sampled points ===
all_points = selected_var3 + selected_var2 + selected_var1 + selected_centers
df = pd.DataFrame(all_points)

# === 7. Prioritize higher Var when duplicates exist ===
# Sort by Var descending so Var=3 rows are kept first
df = df.sort_values(by="Var", ascending=False)
df = df.drop_duplicates(subset=["Point_ID"], keep="first")

# === 8. Save output ===
output_path = "processed_data/test_classified_points.csv"
df.to_csv(output_path, index=False)
print(f"\n✅ Saved '{output_path}' with {len(df)} unique points.")

# === 9. Summary ===
print("\n--- Sample Summary (by Var) ---")
print(df["Var"].value_counts().sort_index())

# === 10. Duplicate check ===
dup_count = df["Point_ID"].duplicated().sum()
if dup_count == 0:
    print("\n✅ No duplicate Point_IDs detected.")
else:
    print(f"\n⚠️ Warning: {dup_count} duplicate Point_IDs remain.")