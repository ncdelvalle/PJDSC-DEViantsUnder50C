"""
Precipitation Data Sampler (Daily Summary)
------------------------------------------
Retrieves 6-month daily precipitation totals from OpenWeatherMap (One Call 3.0)
for 30 observation points across Metro Manila.

Endpoint:
    https://api.openweathermap.org/data/3.0/onecall/day_summary

Sampling: 1 day per week (every 7 days)
Timeframe: 6 months

Output:
    A CSV file with 24 samples per coordinate (≈720 total records)
    Columns: point_id, latitude, longitude, date, precipitation_total
"""

import os
import pandas as pd
import requests
import time
from datetime import datetime, timedelta

# === CONFIGURATION ===
API_KEY =  os.getenv("OWM_API_KEY")
INPUT_CSV = "processed_data/hist_base_points.csv"
OUTPUT_CSV = "raw_data/ncr_1to6_25_C.csv"

# Date range for 6-month batch
start_date = datetime(2024, 7, 31)
end_date = datetime(2025, 12, 31)

# Sample every 7 days (1 day per week)
STEP = timedelta(days=7)

# === LOAD POINTS ===
points = pd.read_csv(INPUT_CSV)
print(f"Loaded {len(points)} coordinates from {INPUT_CSV}")

# === STORAGE ===
records = []

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

            # Extract only precipitation
            precip_data = data.get("precipitation", {})
            precipitation_total = precip_data.get("total")

            record = {
                "point_id": point_id,
                "latitude": data.get("lat", lat),
                "longitude": data.get("lon", lon),
                "date": data.get("date", date_str),
                "precipitation_total": precipitation_total,
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
print(f"\n✅ Precipitation data collection complete! Saved to {OUTPUT_CSV}")