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

