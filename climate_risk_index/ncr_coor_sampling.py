import geopandas as gpd
from shapely.geometry import Point
import numpy as np
import pandas as pd

# === Load NCR GeoJSON ===
ncr_path = "raw_data/ncr_land_admin_border.geojson"
gdf = gpd.read_file(ncr_path)

# Merge MultiPolygon into one shape if needed
ncr_poly = gdf.unary_union

# === Desired number of points ===
target_points = 30

# === Create candidate grid points ===
# Step 1: find bounding box
minx, miny, maxx, maxy = ncr_poly.bounds

# Create a fine grid, then filter by points inside polygon
rows = 10
cols = 10

# Generate evenly spaced lat/lon points within bounding box
x_points = np.linspace(minx, maxx, cols + 2)[1:-1]
y_points = np.linspace(miny, maxy, rows + 2)[1:-1]

candidate_points = [Point(x, y) for y in y_points for x in x_points]

# Filter only those inside NCR polygon
inside_points = [pt for pt in candidate_points if pt.within(ncr_poly)]

# If we got more than 30 points, sample evenly
if len(inside_points) > target_points:
    step = len(inside_points) // target_points
    inside_points = inside_points[::step][:target_points]

# === Create a GeoDataFrame for easy export ===
gdf_points = gpd.GeoDataFrame(geometry=inside_points, crs=gdf.crs)

# Add numeric IDs and lat/lon columns (rounded to 4 decimals)
gdf_points["Point_ID"] = [f"P{i+1:02d}" for i in range(len(gdf_points))]
gdf_points["Latitude"] = gdf_points.geometry.y.round(4)
gdf_points["Longitude"] = gdf_points.geometry.x.round(4)

# === Save to CSV ===
output_csv = "processed_data/ncr_sample_points.csv"
gdf_points[["Point_ID", "Latitude", "Longitude"]].to_csv(output_csv, index=False)

print(f"✅ Saved {len(gdf_points)} interior points to {output_csv}")