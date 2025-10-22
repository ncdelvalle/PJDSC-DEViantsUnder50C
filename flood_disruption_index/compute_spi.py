import pandas as pd
import re

# === 1. Load datasets ===
df = pd.read_csv("processed_data/ncr_synthetic_precip.csv")

# === 2. Read regional mean (μ) and std (σ) from text file ===
with open("processed_data/ncr_regional_stats.txt", "r") as f:
    content = f.read()

mu_match = re.search(r"Regional mean \(μ\): ([0-9.]+)", content)
sigma_match = re.search(r"Regional std \(σ\): ([0-9.]+)", content)

mu = float(mu_match.group(1)) if mu_match else None
sigma = float(sigma_match.group(1)) if sigma_match else None

print(f"Using μ = {mu:.3f}, σ = {sigma:.3f}")

# === 3. Compute SPI ===
# Formula: SPI = (precip - μ) / σ
df["SPI"] = (df["precipitation_total"] - mu) / sigma

# === 4. Normalize SPI to [0, 1] for fuzzy fusion ===
# Clip to [-3, 3] range to avoid extreme outliers
df["SPI_norm"] = df["SPI"].clip(-3, 3)
df["SPI_norm"] = (df["SPI_norm"] + 3) / 6  # shifts to [0, 1]

# === 5. Optional: classify qualitative SPI bins (for interpretability) ===
def classify_spi(x):
    if x < -1.5:
        return "dry"
    elif x < -0.5:
        return "slightly_dry"
    elif x < 0.5:
        return "normal"
    elif x < 1.5:
        return "wet"
    else:
        return "very_wet"

df["SPI_class"] = df["SPI"].apply(classify_spi)

# === 6. Save output ===
df.to_csv("processed_data/ncr_synthetic_SPI.csv", index=False)

print("\n✅ Saved 'ncr_synthetic_SPI.csv' with SPI and normalized SPI values.")
print(df.head())