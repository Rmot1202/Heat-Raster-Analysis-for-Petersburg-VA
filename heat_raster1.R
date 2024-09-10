# READ IN PACKAGES
library(ggnewscale)
library(raster)
library(tidyverse)
library(tidycensus)
library(terra)
library(tigris)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
# library(rgeos)
library(tmap)
library(tmaptools)
library(maps)
library(leaflet)
library(viridis)
library(RColorBrewer)
library(stringr)
# library(rgdal)
library(raster)
library(rasterVis) 

heat_data <- raster("af_t_f.tif")
pburg_data <- get_acs(geography="tract", state="51", county="730",
                    variables=(c(all_pop = "B03002_001", 
                                 white_pop = "B03002_003", 
                                 black_pop = "B03002_004",
                                 latin_pop = "B03002_012",
                                 pov_total = "B06012_001",
                                 pov_count = "B06012_002",
                                 med_income = "B19013_001",
                                 work_household_total = "B08202_001",
                                 work_household_nowork = "B08202_002",
                                 ins_universe= "B27011_001",
                                 emp_noins= "B27011_007",
                                 unemp_noins= "B27011_012",
                                 notlabor_noins= "B27011_017")),
                    geometry=T, cache=T )

pburg_data_wide <- pburg_data %>%
  dplyr::select(-moe) %>%
  spread(variable, estimate)

pburg_data_calc <- pburg_data_wide %>%
  transmute(GEOID= GEOID,
            NAME=NAME,
            tract=str_extract(NAME, "[[:digit:]]{4}"),
            population = all_pop,
            pct_white = white_pop/all_pop * 100,
            pct_black = black_pop/all_pop * 100,
            pct_latin = latin_pop/all_pop * 100,
            pct_minority = (all_pop - white_pop)/all_pop * 100,
            pct_poverty = pov_count/pov_total * 100,
            hhold_nowork = work_household_nowork/work_household_total * 100,
            med_income = med_income,
            pct_uninsured = (emp_noins+unemp_noins+notlabor_noins)/ins_universe * 100)

#transform crs systems
pburg_data_wgs <- st_transform(pburg_data_calc, crs=4326)
heat_data_wgs  <- projectRaster(heat_data, crs="+init=epsg:4326")


plot(heat_data_wgs)
plot(st_geometry(pburg_data_wgs), add=TRUE)

# Read the vector data from the provided file path
##vector_data <- st_read("C:/Users/Raven Mott/Downloads/DSPG/vector_data.shp")

# Define the raster template
##raster_template <- raster(extent(vector_data), res = c(0.0001, 0.0001), crs = st_crs(pburg_data_wgs))

# Rasterize the vector data
##raster_data <- rasterize(vector_data, raster_template, field = "height", fun = max)
##writeRaster(raster_data,"raster.tiff",overwrite=TRUE)

raster_data <- raster("C:/Users/Raven Mott/Downloads/DSPG/raster.tiff")
# Plot the raster data
plot(raster_data)
pbg<-st_geometry(pburg_data_wgs)
sp_object <- as(pbg, "Spatial")
tmax_pbg <- raster::mask( raster_data,sp_object)
my_palette <- colorRampPalette(c("blue", "purple","black"))(100) # 100 color steps
plot(tmax_pbg,col=my_palette ,main="Customized Raster Plot")
plot(st_geometry(pburg_data_wgs),add=T)

#______________________________________________________________________________________________#
# Join building data with census tracts
vector_data <- st_transform(vector_data, st_crs(pburg_data_wgs))

# Now perform the spatial join
building_count_by_tract <- pburg_data_wgs %>%
  st_join(vector_data) %>%
  group_by(geometry) %>%
  summarise(building_count = n(), .groups = 'drop')

# Calculate building density
tracts_with_buildings <- building_count_by_tract %>%
  mutate(building_density = building_count / (st_area(.) / 1e6))  # Area in square kilometers

# Ensure no NA values in building_density
tracts_with_buildings <- tracts_with_buildings %>%
  mutate(building_density = ifelse(is.na(building_density), 0, building_density))

# Define a refined color palette
# Option 1: Custom gradient
color_palette <- colorRampPalette(c("white", "yellow", "orange", "red", "darkred"))(100)

# Option 2: Using RColorBrewer
# color_palette <- brewer.pal(9, "YlOrRd")  # Example using Yellow-Orange-Red palette

# Calculate quantile breaks for building density
quantile_breaks <- quantile(tracts_with_buildings$building_density, probs = seq(0, 1, by = 0.125), na.rm = TRUE)

# Define breaks for the color scale based on quantiles
breaks <- c(0, quantile_breaks)

# Plot the building density with refined color gradient
tm_shape(tracts_with_buildings) +
  tm_polygons(col = "building_density",
              palette = color_palette,
              breaks = breaks,
              title = "Building Density (buildings/km²)") +
  tm_borders()

# Create the map with annotations for building density and count
tm_shape(tracts_with_buildings) +
  tm_polygons(col = "building_density",
              palette = color_palette,
              breaks = breaks,
              title = "Building Density (buildings/km²)") +
  tm_borders() +
  tm_text("building_count", size = 0.5, col = "blue")  # Add building count annotations, slightly offset
tracts_with_buildings_df <- as.data.frame(tracts_with_buildings)

# Write the data frame to a CSV file
tracts_with_buildings_df <- tracts_with_buildings %>%
  mutate(
    building_density = round(building_density, 2),  # Round density for better display
    building_count = as.integer(building_count)
  ) %>%
  select(building_density,building_count,geometry)
write.csv(tracts_with_buildings_df, "tracts_with_buildings.csv", row.names = FALSE)
