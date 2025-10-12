"""
Air Quality Data Sampler (Hourly History)
-----------------------------------------
Retrieves historical hourly air quality data from OpenWeatherMap
(Air Pollution History API) for 30 observation points across Metro Manila.

Endpoint used:
    http://api.openweathermap.org/data/2.5/air_pollution/history

Sampling: 1 day per week (every 7 days)
Timeframe: 6 months
Parameters collected:
    - AQI (Air Quality Index)
    - CO (carbon monoxide)
    - NO (nitric oxide)
    - NO2 (nitrogen dioxide)
    - O3 (ozone)
    - SO2 (sulphur dioxide)
    - PM2.5 (fine particulate matter)
    - PM10 (coarse particulate matter)
    - NH3 (ammonia)

Output:
    A CSV file containing 24 samples per coordinate (≈720 total records)
"""

import os
import pandas as pd
import requests
import time
from datetime import datetime, timedelta

# === CONFIGURATION ===
API_KEY = os.getenv("OWM_API_KEY")
INPUT_CSV = "ncr_sample_points.csv"
OUTPUT_CSV = "ncr_1to6_25_B.csv"

# 6-month range (same as your climate data)
START_DATE = datetime(2025, 1, 1)
END_DATE = datetime(2025, 6, 31)
STEP = timedelta(days=7)  # 1 sample per week

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

    date = START_DATE
    while date <= END_DATE:
        start_unix = int(date.timestamp())
        end_unix = int((date + timedelta(days=1)).timestamp())  # 24-hour window

        url = (
            f"http://api.openweathermap.org/data/2.5/air_pollution/history?"
            f"lat={lat}&lon={lon}&start={start_unix}&end={end_unix}&appid={API_KEY}"
        )

        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()

            if "list" not in data or not data["list"]:
                print(f"⚠️ No AQI data for {point_id} on {date.strftime('%Y-%m-%d')}")
                date += STEP
                continue

            # Compute average of hourly values
            aqi_vals, co_vals, no_vals, no2_vals, o3_vals, so2_vals, pm25_vals, pm10_vals, nh3_vals = ([] for _ in range(9))

            for entry in data["list"]:
                comp = entry["components"]
                aqi_vals.append(entry["main"]["aqi"])
                co_vals.append(comp.get("co"))
                no_vals.append(comp.get("no"))
                no2_vals.append(comp.get("no2"))
                o3_vals.append(comp.get("o3"))
                so2_vals.append(comp.get("so2"))
                pm25_vals.append(comp.get("pm2_5"))
                pm10_vals.append(comp.get("pm10"))
                nh3_vals.append(comp.get("nh3"))

            record = {
                "point_id": point_id,
                "latitude": lat,
                "longitude": lon,
                "date": date.strftime("%Y-%m-%d"),
                "aqi_mean": sum(aqi_vals) / len(aqi_vals),
                "co_mean": sum(co_vals) / len(co_vals),
                "no_mean": sum(no_vals) / len(no_vals),
                "no2_mean": sum(no2_vals) / len(no2_vals),
                "o3_mean": sum(o3_vals) / len(o3_vals),
                "so2_mean": sum(so2_vals) / len(so2_vals),
                "pm2_5_mean": sum(pm25_vals) / len(pm25_vals),
                "pm10_mean": sum(pm10_vals) / len(pm10_vals),
                "nh3_mean": sum(nh3_vals) / len(nh3_vals),
            }

            records.append(record)
            print(f"✅ {point_id} {date.strftime('%Y-%m-%d')} AQI data fetched successfully.")

        except requests.exceptions.RequestException as e:
            print(f"⚠️ Error fetching {point_id} {date.strftime('%Y-%m-%d')}: {e}")

        time.sleep(1)
        date += STEP

# === SAVE RESULTS ===
df = pd.DataFrame(records)
df.to_csv(OUTPUT_CSV, index=False)
print(f"\n✅ AQI data collection complete! Saved to {OUTPUT_CSV}")