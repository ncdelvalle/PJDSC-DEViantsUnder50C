"""
Entropy Weight Calculation (with AQI)
-------------------------------------
Computes Shannon entropy-based weights for environmental indicators
using merged daily summary and air quality datasets.

Now includes:
    - Outlier handling via Winsorization (caps extreme values)
    - Clean normalization and stable entropy computation
    - Prints min & max for each indicator before normalization

Input:
    - ncr_1to6_25_A.csv
    - ncr_7to12_24_A.csv
    - ncr_1to6_25_B.csv
    - ncr_7to12_24_B.csv

Indicators:
    1. temp_mean
    2. humidity_mean
    3. precipitation_total
    4. wind_speed_max
    5. aqi_mean

Output:
    - entropy_weights.csv (weights per variable)
    - normalized merged dataset preview
    - indicator_minmax.csv (optional)
"""

import pandas as pd
import numpy as np
from scipy.stats.mstats import winsorize

# === CONFIGURATION ===
SUMMARY_FILES = ["raw_data/ncr_1to6_25_A.csv", "raw_data/ncr_7to12_24_A.csv"]
AIR_FILES = ["raw_data/ncr_1to6_25_B.csv", "raw_data/ncr_7to12_24_B.csv"]
OUTPUT_FILE = "processed_data/entropy_weights.csv"
MINMAX_FILE = "processed_data/indicator_minmax.csv"

# === LOAD & CONCATENATE DATA ===
print("📂 Loading input CSVs...")

summary_df_list = [pd.read_csv(f) for f in SUMMARY_FILES]
air_df_list = [pd.read_csv(f) for f in AIR_FILES]

summary_df = pd.concat(summary_df_list, ignore_index=True)
air_df = pd.concat(air_df_list, ignore_index=True)

print(f"✅ Summary dataset shape: {summary_df.shape}")
print(f"✅ Air dataset shape: {air_df.shape}")

# === MERGE DATASETS ===
df = pd.merge(summary_df, air_df, on=["latitude", "longitude", "date"], how="inner")
print(f"✅ Merged dataset shape: {df.shape}")

# === SELECT RELEVANT VARIABLES ===
selected = df[[
    "temp_mean", "humidity_mean", "precipitation_total",
    "wind_speed_max", "aqi_mean"
]].copy()

# === CLEAN DATA ===
selected = selected.fillna(selected.mean(numeric_only=True))
selected = selected.round(2)
selected = selected.dropna()  # ensure no NaN remains

# === OUTLIER HANDLING (Winsorization) ===
print("\n⚙️ Applying Winsorization to reduce outlier influence...")
for col in selected.columns:
    selected[col] = winsorize(selected[col], limits=[0.01, 0.01])
print("✅ Winsorization complete.")

# === OPTIONAL TRANSFORM (handle skewed precipitation) ===
if selected["precipitation_total"].skew() > 1:
    selected["precipitation_total"] = np.log1p(selected["precipitation_total"])
    print("📉 Applied log transform to precipitation_total (right-skew detected).")

# === PRINT MIN & MAX FOR EACH INDICATOR ===
print("\n📏 Indicator Min & Max (after cleaning and outlier handling):")
minmax_df = pd.DataFrame({
    "Indicator": selected.columns,
    "Min": selected.min().round(4),
    "Max": selected.max().round(4)
})
print(minmax_df)
minmax_df.to_csv(MINMAX_FILE, index=False)
print(f"✅ Min–Max values saved to {MINMAX_FILE}")

# === NORMALIZATION (Min–Max scaling) ===
normalized = (selected - selected.min()) / (selected.max() - selected.min())
normalized = normalized.clip(1e-10, 1)  # avoid log(0) errors

print("\n🔧 Normalized sample:")
print(normalized.head())

# === SHANNON ENTROPY CALCULATION ===
k = 1 / np.log(len(normalized))
pij = normalized / normalized.sum(axis=0)
entropy = -k * (pij * np.log(pij)).sum(axis=0)

# === CALCULATE WEIGHTS ===
d = 1 - entropy
weights = d / d.sum()

# === SAVE RESULTS ===
weights_df = pd.DataFrame({
    "Indicator": selected.columns,
    "Entropy": entropy.round(4),
    "Weight": weights.round(4)
})

weights_df.to_csv(OUTPUT_FILE, index=False)
print(f"\n✅ Entropy weights saved to {OUTPUT_FILE}")

print("\n📊 Results:")
print(weights_df)

# === OPTIONAL: Weighted Score Preview ===
df["Composite_Score"] = (normalized * weights).sum(axis=1)
print("\n🌍 Sample Composite Scores (rows 750–764):")
print(df.loc[750:764, ["latitude", "longitude", "date", "Composite_Score"]])
