"""
Climate Data Sampler (Daily Summary)
------------------------------------
Retrieves 6-month daily summary data from OpenWeatherMap (One Call 3.0)
for 30 observation points across Metro Manila.

Endpoint used:
    https://api.openweathermap.org/data/3.0/onecall/day_summary

Sampling: 1 day per week (every 7 days)
Timeframe: 6 months
Parameters collected:
    - Temperature (min, max, mean)
    - Humidity (mean from day parts)
    - Pressure (mean from day parts)
    - Wind speed (max)
    - Precipitation (total)
    - Cloud cover (mean from day parts)

Output:
    A CSV file containing 24 samples per coordinate (≈720 total records)
"""

import os
import pandas as pd
import requests
import time
from datetime import datetime, timedelta
import json

# === CONFIGURATION ===
API_KEY = os.getenv("OWM_API_KEY")
INPUT_CSV = "ncr_sample_points.csv"
OUTPUT_CSV = "ncr_1to6_25_A.csv"

# Date range for 6-month batch
start_date = datetime(2025, 1, 1)
end_date = datetime(2025, 6, 30)

# Sample every 7 days (1 day per week)
STEP = timedelta(days=7)

# === LOAD POINTS ===
points = pd.read_csv(INPUT_CSV)
print(f"Loaded {len(points)} coordinates from {INPUT_CSV}")

# === STORAGE ===
records = []

# === HELPER FUNCTION ===
def mean_from_fields(d):
    """Compute mean if multiple day parts exist (morning, afternoon, evening, night)."""
    if not isinstance(d, dict):
        return None
    vals = [v for v in d.values() if isinstance(v, (int, float))]
    return sum(vals) / len(vals) if vals else None


# === MAIN LOOP ===
for _, row in points.iterrows():
    lat = row["Latitude"]
    lon = row["Longitude"]
    point_id = row["Point_ID"]

    date = start_date
    while date <= end_date:
        date_str = date.strftime("%Y-%m-%d")

        url = (
            f"https://api.openweathermap.org/data/3.0/onecall/day_summary?"
            f"lat={lat}&lon={lon}&date={date_str}&appid={API_KEY}&units=metric"
        )

        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()

            # Extract and compute values safely
            temp_data = data.get("temperature", {})
            humidity_data = data.get("humidity", {})
            pressure_data = data.get("pressure", {})
            wind_data = data.get("wind", {}).get("max", {})
            cloud_data = data.get("cloud_cover", {})
            precip_data = data.get("precipitation", {})

            record = {
                "point_id": point_id,
                "latitude": data.get("lat"),
                "longitude": data.get("lon"),
                "date": data.get("date"),
                "temp_min": temp_data.get("min"),
                "temp_max": temp_data.get("max"),
                "temp_mean": mean_from_fields(temp_data),
                "humidity_mean": mean_from_fields(humidity_data),
                "pressure_mean": mean_from_fields(pressure_data),
                "wind_speed_max": wind_data.get("speed"),
                "wind_direction": wind_data.get("direction"),
                "precipitation_total": precip_data.get("total"),
                "cloud_cover_mean": mean_from_fields(cloud_data),
            }

            records.append(record)
            print(f"✅ {point_id} {date_str} fetched successfully.")

        except requests.exceptions.RequestException as e:
            print(f"⚠️ Error fetching {point_id} {date_str}: {e}")

        # Respect rate limit (60 requests/min)
        time.sleep(1)
        date += STEP

# === SAVE RESULTS ===
df = pd.DataFrame(records)
df.to_csv(OUTPUT_CSV, index=False)
print(f"\n✅ Data collection complete! Saved to {OUTPUT_CSV}")