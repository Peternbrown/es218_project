library(dplyr)
library(tmap)
library(tidyr)
library(ggplot2)


# Load the data
health.dat <- read.csv("R11371317_SL050.csv")

# ---- Begin Map Creation ----

# Load Map of the United States
map.usa <- readRDS("gadm36_USA_0_sf.rds")

# Join geo data from health.dat to the USA map
data.map <- left_join(map.usa, health.dat, by = Geo_FIPS)
