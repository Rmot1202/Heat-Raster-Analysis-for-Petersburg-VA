# READ IN PACKAGES

library(tidyverse)
library(tidycensus)
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
library(lubridate)

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
res(heat_data_wgs)

plot(heat_data_wgs)
plot(st_geometry(pburg_data_wgs), add=TRUE)


## write to disk
# writeRaster( heat_data_wgs, "af_t_f_wgs.tif" )


# location of city hall annex and Purple Air monitor
annex <- read_csv("../purpleair/temperature-f.csv")
names(annex) <- c("DateTime","Average","temp_f")
annex_meta <- data.frame( x = -77.40575, y = 37.23011)

### custom plot in ggplot
heat_data_df <- raster::as.data.frame(heat_data_wgs, row.names = NULL, xy = TRUE, na.rm = TRUE)
ggplot( data = heat_data_df, aes(x = x, y = y) ) +
  geom_tile( aes(fill = af_t_f)) +
  geom_sf( data = pburg_data_wgs, inherit.aes = F, fill = NA ) +
  geom_point( data = annex_meta ) +
  scale_fill_gradient(
    name = "Temperature (°C)",
    low = "#FEED99",
    high = "#AF3301"
  )
ggplot( data = heat_data_df, aes(x = x, y = y) ) +
  geom_tile( aes(fill = af_t_f)) +
  geom_sf( data = pburg_data_wgs, inherit.aes = F, fill = NA, col = "white") +
  geom_point( data = annex_meta ) +
  scale_fill_viridis(  ) +
  scale_x_continuous( breaks = c(pretty(heat_data_df$x, n=3)) ) +
  ylab("Latitude") + xlab("Longitude") +
  guides(fill=guide_legend(title = expression(paste("Afternoon\ntemperature (",degree,"F)")) )) +
  theme_minimal() +
  theme( panel.grid.minor = element_blank(),
         panel.grid.major = element_blank() )
ggsave("heat_map_pretty.png", width = 4, height = 4)
#  



### Extract data point in the location of the Purple Air
summary(values(heat_data_wgs))
max_raster <- max( values(heat_data_wgs), na.rm = T)
annex_value <- extract( heat_data_wgs, annex_meta)
max_raster - annex_value
# percentile
quantile(heat_data_wgs, probs = c(0.25, 0.75, .9, .95, .99), type=7,names = FALSE)
# City Hall Annex is in the top 99 percentile of the temperature data

# compare value to measured values over a time series
# duration of data
diff( range( annex$DateTime)) # almost exactly one month
# summary of data
summary(annex$temp_f)
# how often did temperatures exceeds the measurement over the month period
sum(annex$temp_f > annex_value) / length(annex$temp_f)

ggplot( data = annex, aes( x = DateTime, y = temp_f) ) +
  geom_hline( yintercept = annex_value, col = "orange") +
  geom_line() + 
  ylab(expression(paste("Temperature (",degree,"F)")) ) + xlab("Date") +
  theme_classic()
ggsave("purpleair_temp.png", width = 5, height = 3)  



