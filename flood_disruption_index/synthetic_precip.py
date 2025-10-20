import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# === 1. Load points ===
points_file = "processed_data/test_classified_points.csv"
points_df = pd.read_csv(points_file)

# === 2. Load regional stats ===
with open("processed_data/ncr_regional_stats.txt", "r") as f:
    lines = f.readlines()
    mu_region = float(lines[0].split(":")[1].strip())
    sigma_region = float(lines[1].split(":")[1].strip())

print(f"Regional μ={mu_region}, σ={sigma_region}")

# === 3. Define time range ===
base_time = datetime(2025, 10, 19, 12, 0, 0)  # arbitrary base timestamp
hours_before = 6
hours_after = 24

timestamps = [base_time - timedelta(hours=hours_before) + timedelta(hours=i) 
              for i in range(hours_before + hours_after + 1)]

# === 4. Generate synthetic precipitation ===
np.random.seed(42)  # for reproducibility

rows = []
for _, row in points_df.iterrows():
    point_id = row["Point_ID"]
    lat = row["Latitude"]
    lon = row["Longitude"]
    
    for ts in timestamps:
        # Generate realistic precipitation: Normal distribution truncated at 0
        precip = np.random.normal(mu_region, sigma_region)
        precip = max(0, round(precip, 2))  # precipitation can't be negative
        
        # Introduce some zero precipitation to simulate dry periods
        if np.random.rand() < 0.2:  # 20% chance of zero rain
            precip = 0.0
        
        rows.append({
            "point_id": point_id,
            "latitude": lat,
            "longitude": lon,
            "timestamp": ts.isoformat(),
            "precipitation_total": precip,
            "source": "synthetic"
        })

# === 5. Create DataFrame and save ===
synthetic_df = pd.DataFrame(rows)
synthetic_df.to_csv("processed_data/ncr_synthetic_precip.csv", index=False)

print("✅ Synthetic precipitation dataset saved as 'ncr_synthetic_precip.csv'")
print("Sample:")
print(synthetic_df.head(10))