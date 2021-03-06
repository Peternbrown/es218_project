library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)
library(USAboundaries)
library(tmap)

# Set working directory
# Load the data (found in the repository, Health/data/...)
health.dat <- read.csv(url("https://raw.githubusercontent.com/Peternbrown/es218_project/master/Health/data/R11371317_SL050.csv"))

# Load county income data
income.dat <- read.csv(url("https://raw.githubusercontent.com/Peternbrown/es218_project/master/Health/data/County_GDP_percapita.csv"))

# ---- CLEAN AND PREPARE DATA ----

# Create state only income data
income.state <- income.dat %>% 
  select(-Rank, -County.or.county.equivalent) %>% 
  add_column("Geo_STATE" = c(1, 2, 4:6, 8:10, 12, 13, 15:42, 44:51, 53:56))

# Remove uneeded columns from health data
health.dat2 <- health.dat %>% 
  select(Geo_STATE, SE_T001_001, SE_T001_002, SE_T004_001, SE_T004_002,
          SE_T008_004, SE_T005_001, SE_NV003_001, SE_NV003_002, SE_NV006_004) %>% 
  rename("Physically Unhealthy Days per Month"                      = SE_T001_001,
         "Mentally Unhealthy Days per Month"                        = SE_T001_002,
         "Primary Care Physicians (PCP)"                            = SE_T004_001,
         "Mental Health Providers (MHP)"                            = SE_T004_002,
         "Health Care Costs Price-adjusted Medicare Reimbursements" = SE_T005_001,
         "Drug Poisoning Mortality Count"                           = SE_T008_004,
         "Drug Poisoning Mortality Rate"                            = SE_NV006_004,
         "PCP per 100,000 people"                                   = SE_NV003_001,
         "MHP per 100,000 people"                                   = SE_NV003_002) %>% 
  group_by(Geo_STATE) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  mutate_all(funs(round(., digits = 2)))

# Join the income and health tables
all.data <- inner_join(health.dat2, income.state, by = "Geo_STATE") %>% 
  rename("State" = State..federal.district.or.territory)

# Create New-England only data
ne.dat <- all.data %>% 
  filter(State %in% c("Maine", "New Hampshire", "Vermont", "Massachusetts", "Connecticut", "Rhode Island")) %>% 
           rename("state_name" = State)

# Create New England Counties
attach(health.dat)
ne.counties <- health.dat[order(Geo_FIPS), ]
detach(health.dat)

ne.counties2 <- ne.counties %>%
  filter(Geo_FIPS %in% c("9001", "9003", "9005", "9007" , "9009" , "9011" , "9013" , "9015", "23001", "23003", "23005", "23007", "23009", 
                         "23011", "23013", "23015", "23017", "23019", "23021", "23023", "23025", "23027", "23029", "23031", "25001", "25003", 
                         "25005", "25007", "25009", "25011", "25013", "25015", "25017", "25019", "25021", "25023", "25025", "25027", "33001", 
                         "33003", "33005", "33007", "33009", "33011", "33013", "33015", "33017", "33019", "44001", "44003", "44005", "44007", 
                         "44009", "50001", "50003", "50005", "50007", "50009", "50011", "50013", "50015", "50017", "50019", "50021", "50023", 
                         "50025", "50027")) %>% 
  select(Geo_STATE, Geo_NAME, Geo_QNAME, SE_T001_001, SE_T001_002, SE_T004_001, SE_T004_002,
         SE_T008_004, SE_T005_001, SE_NV003_001, SE_NV003_002, SE_NV006_004) %>% 
  rename("Physically Unhealthy Days per Month"                      = SE_T001_001,
         "Mentally Unhealthy Days per Month"                        = SE_T001_002,
         "Primary Care Physicians (PCP)"                            = SE_T004_001,
         "Mental Health Providers (MHP)"                            = SE_T004_002,
         "Health Care Costs Price-adjusted Medicare Reimbursements" = SE_T005_001,
         "Drug Poisoning Mortality Count"                           = SE_T008_004,
         "Drug Poisoning Mortality Rate"                            = SE_NV006_004,
         "PCP per 100,000 people"                                   = SE_NV003_001,
         "MHP per 100,000 people"                                   = SE_NV003_002) %>% 
  add_column(State = c("Connecticut", "Connecticut", "Connecticut", "Connecticut", "Connecticut", "Connecticut", "Connecticut",
                       "Connecticut", "Maine", "Maine", "Maine", "Maine", "Maine", "Maine", "Maine", "Maine", "Maine", "Maine", 
                       "Maine", "Maine", "Maine", "Maine", "Maine", "Maine", "Massachusetts", "Massachusetts", "Massachusetts", 
                       "Massachusetts", "Massachusetts", "Massachusetts", "Massachusetts", "Massachusetts", "Massachusetts", 
                       "Massachusetts",  "Massachusetts", "Massachusetts", "Massachusetts", "Massachusetts", "New Hampshire", 
                       "New Hampshire", "New Hampshire", "New Hampshire", "New Hampshire", "New Hampshire", "New Hampshire", 
                       "New Hampshire",  "New Hampshire",  "New Hampshire", "Rhode Island", "Rhode Island", "Rhode Island",
                       "Rhode Island", "Rhode Island", "Vermont", "Vermont", "Vermont", "Vermont", "Vermont", "Vermont", "Vermont", 
                       "Vermont", "Vermont", "Vermont", "Vermont", "Vermont", "Vermont", "Vermont"))

# ---- BEGIN ANALYSIS ----

# ---- Maps and Intro ----

# Create New England states only and shapefile

ne.map <- us_states(states = c("Massachusetts", "Vermont", "Maine",
                               "New Hampshire", "Rhode Island",
                               "Connecticut"))

ne.shp <- full_join(ne.map, ne.dat, by = "state_name")


# Map household income
tmap_options(max.categories = 6)

income.map <- tm_shape(ne.shp, projection = 26919) + 
  tm_polygons("Medianhouseholdincome", style = "quantile", n = 6, palette = "Greens") +
  tm_legend(outside = TRUE)

# Map drug mortality
drug.map <- tm_shape(ne.shp, projection = 26919) + 
  tm_polygons("Drug Poisoning Mortality Rate", style = "quantile", n = 6, palette = "Reds") +
  tm_legend(outside = TRUE)

# Map mental health providers
MHP.map <- tm_shape(ne.shp, projection = 26919) + 
  tm_polygons("MHP per 100,000 people",
              style = "quantile", n = 6, palette = "Blues") +
  tm_legend(outside = TRUE)


mentally_unhealthy.map <- tm_shape(ne.shp, projection = 26919) + 
  tm_polygons("Mentally Unhealthy Days per Month",
              style = "quantile", n = 6, palette = "Purples") +
  tm_legend(outside = TRUE)

# side-by-side maps (change figure size when knitting)
tmap_arrange(income.map, drug.map, MHP.map, mentally_unhealthy.map, 
             nrow = 2, ncol = 2)

# ---- plot mean mental health per 100,000 and median income -------------------------------------------

ggplot(all.data, aes(x = `Medianhouseholdincome`, y = `MHP per 100,000 people`)) + geom_point() + xlab("Median Household Income") +
  theme(axis.text.x = element_text(angle = 90))

# ---- qq-plot of all new england counties' drug mortality rate ----

ggplot() + aes(sample = ne.counties2$`Drug Poisoning Mortality Rate`) + geom_qq(distribution = qnorm) + 
  geom_qq_line(line.p = c(0.25, 0.75), col = "red") + ylab("Drug Poisoning Mortality Rate") +
  ggtitle("Theoretical Q-Q Plot of New England Counties' Drug Poisoning Mortality Rates")

# plot against access to mental health care providers

ggplot(ne.counties2, aes(x = `Drug Poisoning Mortality Rate`, y = `MHP per 100,000 people`)) +
  geom_point() + stat_smooth(method = "loess", se = FALSE, span = 0.9)

# plot mentally unhealthy days against drugs
ggplot(ne.counties2, aes(x = `Drug Poisoning Mortality Rate`, y = `Mentally Unhealthy Days per Month`)) +
  geom_point()

# ---- Residuals for mental health provider and income----
res <- lm(`MHP per 100,000 people` ~ Medianhouseholdincome, dat = all.data)

all.data$residuals <- residuals(res)                      

ggplot(all.data, aes(x = Medianhouseholdincome, y = residuals)) + geom_point() +
  stat_smooth(method = "loess", se = FALSE, span = 1, 
              method.args = list(degree = 1) )




# Remove $ from medianhouseholdincome
library(stringr)
all.data <- all.data %>%  
  mutate( income = str_replace(Medianhouseholdincome, "\\$", ""),
          income = str_replace(income, ",", ""),
          income = as.numeric(income))

ggplot(all.data, aes(x = income, y = `MHP per 100,000 people`)) + geom_point() + xlab("Median Household Income") +
  theme(axis.text.x = element_text(angle = 90))
