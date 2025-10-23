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

\[
k = \frac{1}{\ln(n)}
\]

\[
p_{ij} = \frac{x_{ij}}{\sum_{i=1}^{m} x_{ij}}
\]

\[
e_j = -k \sum_{i=1}^{m} p_{ij} \ln(p_{ij})
\]

where:  
- \( n \) = number of indicators  
- \( m \) = number of samples  
- \( x_{ij} \) = normalized value of the \( j^{th} \) metric at point \( i \)  
- \( e_j \) = entropy value of the \( j^{th} \) metric  

The **weight** of each metric is then computed as:

\[
w_j = \frac{1 - e_j}{\sum_{j=1}^{n} (1 - e_j)}
\]

---

## 📈 III. Key Outputs

- ✅ **Shannon Entropy Weights** for each climate metric  
- ✅ **Regional Minimum and Maximum** for each metric (used in normalization)

These outputs are stored as CSV or JSON files for downstream analysis.

---

## 📱 IV. Climate Risk Index Computation (in Flutter)

The final **Climate Risk Index (CRI)** is computed within the **Flutter application** using the **Weighted Arithmetic Mean Index** formula:

\[
CRI_i = \frac{\sum_{j=1}^{n} (w_j \times x_{ij})}{\sum_{j=1}^{n} w_j}
\]

where:  
- \( CRI_i \) = Climate Risk Index of sample point \( i \)  
- \( w_j \) = Shannon entropy weight of metric \( j \)  
- \( x_{ij} \) = normalized value of metric \( j \) at point \( i \)

Higher **CRI** values indicate greater climate-related risk intensity at that location.

