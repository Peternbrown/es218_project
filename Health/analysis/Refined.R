library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)

# Set working directory
# Load the data (found in the repository, Health/data/...)
health.dat <- read.csv("R11371317_SL050.csv")

# Load county income data
income.dat <- read.csv("County_GDP_percapita.csv")

# Create state only income data
income.state <- income.dat %>% 
  select(-Rank, -County.or.county.equivalent) %>% 
  add_column("Geo_STATE" = c(1, 2, 4:6, 8:10, 12, 13, 15:42, 44:51, 53:56))


# Remove uneeded columns from health data
health.dat2 <- health.dat %>% 
  select(Geo_STATE, SE_T001_001, SE_T001_002, SE_T004_001, SE_T004_002,
          SE_T008_004, SE_T005_001) %>% 
  rename("Physically Unhealthy Days per Month"                      = SE_T001_001,
         "Mentally Unhealthy Days per Month"                        = SE_T001_002,
         "Primary Care Physicians (PCP)"                            = SE_T004_001,
         "Mental Health Providers (MHP)"                            = SE_T004_002,
         "Health Care Costs Price-adjusted Medicare Reimbursements" = SE_T005_001,
         "Drug Poisoning Mortality"                                 = SE_T008_004) %>% 
  group_by(Geo_STATE) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  mutate_all(funs(round(., digits = 2)))

# Join the income and health tables
all.data <- inner_join(health.dat2, income.state, by = "Geo_STATE") %>% 
  rename("State" = State..federal.district.or.territory)
