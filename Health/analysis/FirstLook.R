library(dplyr)
library(tmap)
library(tidyr)
library(ggplot2)
library(sf)

# Set working directory
# Load the data (found in the repository, Health/data/...)
health.dat <- read.csv("R11371317_SL050.csv")

# Load county income data
income.dat <- read.csv("County_GDP_percapita.csv")

# Join the income data to the health data table
income.dat <- income.dat %>% 
  rename("Geo_NAME" = County.or.county.equivalent)

full.dat <- full_join(health.dat, income.dat, by = "Geo_NAME") # Check back on this later (Counties from different states are being combined) ----

# Remove uneeded columns and rows
full.dat2 <- full.dat %>% 
  select(Geo_FIPS, Geo_NAME, Geo_STATE, SE_T001_001, SE_T001_002, SE_T004_001, SE_T004_002,
         SE_T008_004, SE_T005_001, Population, Per.capitaincome, Medianhouseholdincome, 
         State..federal.district.or.territory)





# Condense the data from county level up to state level
health.state <- health.dat %>% 
  select(-Geo_FIPS, - Geo_NAME, -Geo_COUNTY) %>% 
  reshape(health.state, varrying=c("Geo_NAME", ))





# ---- Begin Map Creation ----

# Load Map of the United States
map.usa <- readRDS()

# Join geo data from health.dat to the USA map
data.map <- left_join(map.usa, health.dat, by = "Geo_FIPS")
