

# Heat Raster Analysis for Petersburg, VA

This R script performs a heat raster analysis for Petersburg, Virginia, combining temperature data with demographic information. It visualizes the afternoon temperature distribution across the city and compares it with various socio-economic factors.

## Features

- **Heat Raster Analysis**: Processes and visualizes the afternoon temperature across Petersburg using spatial data.
- **Demographic Integration**: Retrieves and combines census demographic data for deeper analysis.
- **Visual Comparisons**: Displays relationships between temperature, tree cover, population density, and socio-economic variables.
- **Time Series Temperature Data**: Compares Purple Air monitor data to spatial temperature patterns.
- **Statistical Analysis**: Includes percentile calculations, correlations, and regression analysis.

## Dependencies

Make sure to install the following R packages before running the script:

- `tidyverse`
- `tidycensus`
- `tigris`
- `sf`
- `rnaturalearth`
- `rnaturalearthdata`
- `tmap`
- `tmaptools`
- `maps`
- `leaflet`
- `viridis`
- `RColorBrewer`
- `stringr`
- `raster`
- `rasterVis`
- `lubridate`

Install the packages using the `install.packages("package_name")` command in R.

## Usage

1. **Prepare Data**:
    - Place the heat raster file (`af_t_f.tif`) in the same directory as the script.
    - Add the `temperature-f.csv` file in the `../purpleair/` directory for time series analysis.
2. **Set Census API**: Ensure a valid Census API key is available for retrieving demographic data (`tidycensus`).
3. **Run the Script**: Execute the script in R or RStudio.
4. **Output Files**: Visualizations will be saved as:
    - `heat_map_pretty.png`: A detailed heatmap showing temperature variations.
    - `purpleair_temp.png`: A time series plot comparing Purple Air temperature data.

## Data Sources

- **Temperature Data**: Heat raster provided as `af_t_f.tif`.
- **Demographic Data**: Sourced from the U.S. Census Bureau via the `tidycensus` package.
- **Air Monitor Data**: Time series data from the Purple Air monitor, available in `temperature-f.csv`.

## Analysis Overview

- **Raster Visualization**: Displays census tracts with overlaid heat data.
- **Tree Cover and Population**: Compares the temperature variations with socio-economic factors like tree coverage and building density.
- **Correlation Analysis**: Includes statistical correlations (e.g., negative relationship between tree cover and temperature).
- **Specific Focus**: The City Hall Annex location is used for localized comparisons.

## Key Insights

- **Negative Tree Cover Correlation**: The analysis shows a strong negative correlation between temperature and tree cover.
- **Population and Building Density**: Higher population/building density regions show varying temperature effects.
- **Purple Air Data**: Detailed time-based temperature insights are provided by the Purple Air monitor data.


