# PJDSC-DEViantsUnder50C
# 🌦️ Climate Risk Index (CRI)

This folder contains the preprocessing of the **Climate Risk Index** for the National Capital Region (NCR), Philippines, using historical weather and air quality data obtained from **OpenWeatherMap (OWM)** APIs.  
The CRI will serve as a regional indicator for climate-related stressors affecting last-mile delivery riders across Metro Manila.

---

## 🗂️ I. Datasets

### a. OpenWeatherMap Historical Records  
Climate metrics sampled from **July 2024 to June 2025**, divided into two data sets:

- **Set A:** Temperature (°C), Humidity (%), Precipitation (mm), and Wind Speed (m/s)  
- **Set B:** Air Quality Index (AQI)

### b. NCR Land Administration Border  
- Polygon boundary of **Metro Manila** generated using [geojson.io](https://geojson.io).

---

## ⚙️ II. Processes

### a. Coordinate Sampling — `ncr_coor_sampling.py`
Generates **30 spatially distributed points** across Metro Manila.  
These coordinates serve as sampling sites for weather and AQI data collection.

### b. OpenWeatherMap API Calls
- **`climate_API_call.py`** — Fetches data for Set A metrics (temperature, humidity, precipitation, wind speed).  
- **`aqi_API_call.py`** — Fetches data for Set B (Air Quality Index).

### c. Data Cleaning and Weight Calculation — `shannon_weight.py`
Performs the following steps:
1. **Data Cleaning:** Handles missing or inconsistent entries.  
2. **Outlier Treatment:** Uses *Winsorization* to cap extreme values.  
3. **Normalization:** Each metric is scaled to its regional **min–max range**.  
4. **Entropy Weight Computation:** Uses the Shannon entropy method to determine metric weights.

The Shannon Entropy weight is calculated as:

<img width="90" height="51" alt="CodeCogsEqn (9)" src="https://github.com/user-attachments/assets/bb2de0c3-5e1d-4178-95a0-c92daf9e25c8" />
<img width="134" height="46" alt="CodeCogsEqn (8)" src="https://github.com/user-attachments/assets/240b1618-bd6b-4863-969f-d41f456ff614" />
<img width="199" height="60" alt="CodeCogsEqn (7)" src="https://github.com/user-attachments/assets/e77687d6-2f8c-4c4c-bc24-27c0bb7e8046" />

where:  
- \( n \) = number of indicators  
- \( m \) = number of samples  
- \( x<sub>ij</sub> \) = normalized value of the \( j<sup>th</sup>} \) metric at point \( i \)  
- \( e<sub>j</sub> \) = entropy value of the \( j<sup>th</sup> \) metric  

The **weight** of each metric is then computed as:

<img width="177" height="54" alt="CodeCogsEqn (6)" src="https://github.com/user-attachments/assets/b76600d9-9c99-45af-b852-116deb07099f" />

---

## 📈 III. Key Outputs

- ✅ **Shannon Entropy Weights** for each climate metric  
- ✅ **Regional Minimum and Maximum** for each metric (used in normalization)

These outputs are stored as CSV or JSON files for downstream analysis.

---

## 📱 IV. Climate Risk Index Computation (in Flutter)

The final **Climate Risk Index (CRI)** is computed within the **Flutter application** using the **Weighted Arithmetic Mean Index** formula:

<img width="222" height="59" alt="CodeCogsEqn (5)" src="https://github.com/user-attachments/assets/b7f3d906-852f-4f58-893f-f28a08cdc2e1" />

where:  
- \( CRI<sub>i</sub> \) = Climate Risk Index of sample point \( i \)  
- \( w<sub>j</sub> \) = Shannon entropy weight of metric \( j \)  
- \( x<sub>ij</sub> \) = normalized value of metric \( j \) at point \( i \)

Higher **CRI** values indicate greater climate-related risk intensity at that location.

---
# 🌊 Flood Risk Index (FRI)

This project computes a **Flood Risk Index** for the National Capital Region (NCR), Philippines, by combining precipitation-based flood potential with spatial hazard classifications.  
It integrates both **historical precipitation trends** and **forecasted rainfall conditions** to estimate potential flood risk intensity.

---

## 🗂️ I. Datasets

### a. OpenWeatherMap Historical Records  
- Historical precipitation samples covering **July 2024 to June 2025**  
- Sampled from **30 coordinate points** across Metro Manila

### b. OpenWeatherMap Forecast Data  
- **Current**, **48-hour**, and **hourly forecast** precipitation from the OWM API  

### c. Project Noah NCR Dataset  
- Transformed from shapefile (`.shp`) to **GeoJSON** format  
- Used to define baseline **risk zones** (no risk, low, moderate, high)

---

## ⚙️ II. Processes

### a. OpenWeatherMap API Calls  
- **`historical_api_call.py`** — Fetches past precipitation data for the 30 sample points  
- **`current_forecast_api_call.py`** — Collects real-time and forecast precipitation data from OWM

### b. Historical Statistics — `historical_precip_stats.py`
Computes the **regional mean (μ)** and **standard deviation (σ)** of precipitation for the July 2024–June 2025 period. These serve as parameters for the Standardized Precipitation Index (SPI) and synthetic dataset generation.

### c. Risk-Based Sampling — `point_sampling.py`
Generates sample points located in **no**, **low**, **moderate**, and **high-risk** areas based on the Project Noah GeoJSON flood zones.

### d. Balanced Dataset Creation — `clean_sample_points.py`
Filters and balances sampled points to achieve a **66:34:40:60 ratio** for the four risk classifications to ensure model representativeness.

### e. Synthetic Data Generation — `synthetic_precip.py`
Since forecasted and current precipitation data alone are insufficient to represent edge-case rainfall scenarios, synthetic data are generated using the regional mean and standard deviation derived from historical records.
This simulates semi-realistic but diverse precipitation situations across the region. Synthetic precipitation values are produced using a normal distribution centered around the regional mean.

### f. SPI Calculation — `compute_spi.py`
Computes the **Standardized Precipitation Index (SPI)** to standardize rainfall anomalies:

<img width="130" height="45" alt="CodeCogsEqn (10)" src="https://github.com/user-attachments/assets/96b0d5d2-f394-41ec-bf2c-72e1f4e239b2" />

- \( w<sub>l</sub> \) = weights for low, medium, and high levels  
- \( γ \) = balance between AND/OR logic 
- \( H<sub>l</sub> \) = Hazard Level 
- \( S<sub>l</sub> \) = SPI Level

Values are **clipped** to the range \([-3, 3]\) for outlier handling, then **normalized** to [0,1]

Classification:
| SPI Range | Category |
|------------|-----------|
| ≤ -1.5     | Dry |
| (-1.5, -0.5] | Slightly Dry |
| (-0.5, 0.5] | Normal |
| (0.5, 1.5]  | Wet |
| > 1.5      | Very Wet |

### g. Fuzzy Fusion of SPI and Hazard — `fdi_fuzzy_fusion.py`
The Flood Disruption Index (FDI) combines the hazard intensity (from Project Noah data) and precipitation potential (from normalized SPI) using fuzzy logic. Each variable is transformed into “low”, “medium”, and “high” fuzzy memberships, then merged using a weighted fuzzy fusion formula. 

<img width="533" height="50" alt="CodeCogsEqn (12)" src="https://github.com/user-attachments/assets/1051698d-4718-40bc-97b0-154c35334eac" />

- \( p \) = current precipitation total  
- \( μ \) = regional mean for precipitation
- \( σ \) = regional standard deviation for precipitation

---

## 📈 III. Key Outputs

- ✅ **Regional mean (μ) and standard deviation (σ)** for NCR precipitation  
- ✅ **Normalized SPI values** and classifications  
- ✅ **Flood Disruption Index (FDI)** per location point  
- ✅ **FDI classification map** (Low / Medium / High risk)

## 🔧 IV. Implementation Note: Integration Between Python and Flutter
The Standardized Precipitation Index (SPI) and Flood Disruption Index (FDI) computations are implemented directly inside the Flutter application, ensuring real-time calculation and visualization within the mobile or web environment.

However, a crucial preprocessing step—the sampling of geographic points from routes (used to associate FDI values with specific locations)—cannot be performed natively in Flutter due to the lack of advanced geospatial and scientific libraries (e.g., geopandas, shapely, or rasterio).

To address this limitation:
- The point sampling and spatial processing are handled by a Python backend program, which performs geographic interpolation, spatial joins, and dataset preparation.
- This Python process is hosted on a cloud service, allowing the Flutter frontend to request processed spatial data through an API endpoint before applying SPI and FDI computations.

---

## 🔧 IV. Implementation Note: Integration Between Python and Flutter

- Python backend handles **geospatial preprocessing** (sampling, interpolation, spatial joins).  
- Flutter frontend performs **CRI, SPI, and FDI computations** using preprocessed data.  
- Python is hosted on a **cloud service** to provide API endpoints for Flutter requests.

---

## 🛠️ V. Tech Stack

| Layer | Technology |
|-------|------------|
| Backend / Data Processing | Python 3.11+, pandas, numpy |
| APIs | OpenWeatherMap API |
| Mobile / Frontend | Flutter 3.13+, Dart |
| Data Storage | CSV, JSON |
| Visualization | Flutter charts, maps (e.g., `flutter_map` or `google_maps_flutter`) |

---

## 💻 VI. Installation

**Clone the repository**
```bash
git clone https://github.com/<username>/PJDSC-DEViantsUnder50C.git
cd PJDSC-DEViantsUnder50C

---

## ▶️ Execution: Flutter Frontend

> Main execution happens here. Flutter handles CRI, SPI, and FDI computations and visualization.

```bash
# Enter Flutter project directory
cd flutter_app

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
