import pandas as pd
import numpy as np

# === 1. Load datasets ===
df_spi = pd.read_csv("processed_data/ncr_synthetic_SPI.csv")       # contains columns: point_id, SPI, SPI_norm, SPI_class, precipitation_total, etc.
df_hazard = pd.read_csv("processed_data/test_classified_points.csv") # contains: Point_ID, Var, Latitude, Longitude

# Merge on point_id only
df = pd.merge(df_spi, df_hazard[["Point_ID","Var","Latitude","Longitude"]],
              left_on="point_id", right_on="Point_ID", how="left")
df.drop(columns=["Point_ID"], inplace=True)

# === 2. Fuzzification functions ===
def fuzz_hazard(var):
    """
    Compressed hazard fuzzification: Var=0 none, 1 low, 2 medium, 3 high
    Compress Var 2 & 3 slightly toward Var 1 to avoid extreme jumps
    """
    memberships = {}
    # Scale to [0,1] and compress higher values
    compressed_var = (var / 3) ** 0.8  # compress high hazards
    
    memberships["low"] = max(0, min(1, 1 - compressed_var))  # decreases with hazard
    memberships["medium"] = max(0, min(1, 1 - abs(compressed_var - 0.3)/0.3))  # peak near medium hazard
    memberships["high"] = max(0, min(1, compressed_var))  # increases with hazard
    
    return memberships

def fuzz_spi(spi_norm):
    """
    SPI fuzzification: normalized SPI in [0,1]
    SPI=0.5 (mean) gives medium=1, low decreases, high increases gradually
    """
    memberships = {}
    memberships["low"] = max(0, min(1, (0.6 - spi_norm)/0.6))
    memberships["medium"] = max(0, 1 - abs(spi_norm - 0.5)/0.5)
    memberships["high"] = max(0, min(1, (spi_norm - 0.4)/0.6))
    return memberships

# === 3. Compute FDI ===
gamma = 0.9
weights = {"low":0.3, "medium":0.6, "high":1.0}
fdi_values = []

for idx, row in df.iterrows():
    hazard_fuzzy = fuzz_hazard(row["Var"])
    spi_fuzzy = fuzz_spi(row["SPI_norm"])
    
    fdi = 0
    for level in ["low","medium","high"]:
        h = hazard_fuzzy[level]
        s = spi_fuzzy[level]
        w = weights[level]
        # AND + OR fuzzy fusion
        fdi += w * (gamma * (h*s) + (1-gamma)*(h + s - h*s))
    
    # small base FDI if no precipitation (ensures low hazard not zero)
    if row["precipitation_total"] == 0:
        fdi += 0.05 * hazard_fuzzy["low"]
    
    fdi_values.append(fdi)

df["FDI"] = fdi_values

# === 4. Classify FDI ===
def classify_fdi(fdi):
    if fdi < 0.3:
        return "low"
    elif fdi < 0.6:
        return "medium"
    else:
        return "high"

df["FDI_class"] = df["FDI"].apply(classify_fdi)

# === 5. Save final CSV ===
cols_order = ["point_id","Latitude","Longitude","timestamp","precipitation_total","source",
              "SPI","SPI_norm","SPI_class","Var","FDI","FDI_class"]

df[cols_order].to_csv("processed_data/ncr_synthetic_FDI.csv", index=False)
print("✅ Saved 'ncr_synthetic_FDI.csv' with FDI and classifications")
print(df[cols_order].head(10))