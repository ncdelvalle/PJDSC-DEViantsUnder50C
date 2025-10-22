import pandas as pd

# === 1. Load both CSVs ===
file1 = "raw_data/ncr_1to6_25_C.csv"
file2 = "raw_data/ncr_7to12_24_C.csv"

df1 = pd.read_csv(file1)
df2 = pd.read_csv(file2)

# Combine both into one dataframe
df = pd.concat([df1, df2], ignore_index=True)

# Optional: check structure
print("Columns:", df.columns.tolist())
print("Number of rows:", len(df))

# === 2. Ensure data types ===
df["date"] = pd.to_datetime(df["date"], errors="coerce")
df["precipitation_total"] = pd.to_numeric(df["precipitation_total"], errors="coerce")

# Drop missing values (if any)
df = df.dropna(subset=["precipitation_total", "point_id"])

# === 3. Compute Regional Mean and Std Dev (μ_region, σ_region) ===
mu_region = df["precipitation_total"].mean()
sigma_region = df["precipitation_total"].std()

print("\n--- Regional Statistics ---")
print(f"Regional mean (μ): {mu_region:.3f} mm")
print(f"Regional std. dev. (σ): {sigma_region:.3f} mm")

# === 4. Compute Per-Point (Local) Mean and Std Dev ===
point_stats = (
    df.groupby("point_id")["precipitation_total"]
    .agg(["mean", "std"])
    .reset_index()
    .rename(columns={"mean": "mu_local", "std": "sigma_local"})
)

print("\n--- Sample of Per-Point Statistics ---")
print(point_stats.head())

# === 5. Save outputs ===
# Save point-level μ and σ for use in SPI calculations later
point_stats.to_csv("ncr_point_stats.csv", index=False)
print("\n✅ Saved 'ncr_point_stats.csv' with μ_local and σ_local for each point.")

# Optional: Save regional stats in a small text or CSV file
with open("ncr_regional_stats.txt", "w") as f:
    f.write(f"Regional mean (μ): {mu_region}\n")
    f.write(f"Regional std (σ): {sigma_region}\n")

print("✅ Saved 'ncr_regional_stats.txt' for reference.")