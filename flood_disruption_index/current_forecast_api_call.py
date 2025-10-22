"""
Precipitation Data Sampler (Current + Forecast)
-----------------------------------------------
Retrieves current and 48-hour hourly forecast precipitation totals
from OpenWeatherMap (One Call 3.0) for multiple observation points.

Endpoint:
    https://api.openweathermap.org/data/3.0/onecall

Output:
    A CSV file with precipitation data per coordinate and timestamp.
    Columns: point_id, latitude, longitude, timestamp, precipitation_total, source
"""

import os
import pandas as pd
import requests
import time
from datetime import UTC, datetime

# === CONFIGURATION ===
API_KEY = os.getenv("OWM_API_KEY")
INPUT_CSV = "processed_data/test_classified_points.csv"
OUTPUT_CSV = "raw_data/ncr_current_forecast_precip.csv"

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

    url = (
        f"https://api.openweathermap.org/data/3.0/onecall?"
        f"lat={lat}&lon={lon}&appid={API_KEY}&units=metric&exclude=minutely,daily,alerts"
    )

    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

        # === CURRENT PRECIPITATION ===
        current = data.get("current", {})
        current_precip = 0.0
        if "rain" in current:
            current_precip = current["rain"].get("1h", 0.0)
        elif "snow" in current:
            current_precip = current["snow"].get("1h", 0.0)

        records.append({
            "point_id": point_id,
            "latitude": lat,
            "longitude": lon,
            "timestamp": datetime.fromtimestamp(current.get("dt", 0), UTC).isoformat(),
            "precipitation_total": current_precip,
            "source": "current"
        })
        print(f"✅ Current data fetched for {point_id}")

        # === HOURLY FORECAST PRECIPITATION ===
        hourly_data = data.get("hourly", [])
        for hour in hourly_data:
            precip = 0.0
            if "rain" in hour:
                precip = hour["rain"].get("1h", 0.0)
            elif "snow" in hour:
                precip = hour["snow"].get("1h", 0.0)

            records.append({
                "point_id": point_id,
                "latitude": lat,
                "longitude": lon,
               "timestamp": datetime.fromtimestamp(current.get("dt", 0), UTC).isoformat(),
                "precipitation_total": precip,
                "source": "forecast"
            })

        print(f"🌧 Forecast data (48h) fetched for {point_id}")

    except requests.exceptions.RequestException as e:
        print(f"⚠️ Error fetching data for {point_id}: {e}")

    # Respect OWM rate limits (~60 requests/min)
    time.sleep(1)

# === SAVE RESULTS ===
df = pd.DataFrame(records)
df.to_csv(OUTPUT_CSV, index=False)
print(f"\n✅ Data collection complete! Saved to {OUTPUT_CSV}")

# === Optional Summary ===
print("\n--- Summary ---")
print(df["source"].value_counts())