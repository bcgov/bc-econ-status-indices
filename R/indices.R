# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


## Source setup and function scripts
if (!exists(".setup_sourced")) source(here::here("R/setup.R"))

# import two datasets
## synthetic data
synthetic_data <- fread(here::here("input-data", "synthetic-data.csv"))

## t1 income tax data for individuals (table 1)
tax_data <- fread(here::here("input-data", "1_IND.csv"))

#-------------------------------------------------------------------------------

# Make data ready for index generation
## merge tax data and synthetic data tables (here named `linked_data``)

synthetic_data_linkage <- synthetic_data %>%
  select(studyid, `postal|area`, `level|of|geo`, key_1, key_2, key_3, key_4) # may take other fields as necessary

tax_data_linkage <- tax_data %>%
  select(`year`, `postal|area`, `place|name|geo`, `total|income|median|total`) # may take other fields as necessary

linked_data <- full_join(tax_data_linkage, synthetic_data_linkage, by = "postal|area")

# check whether data has NA's after left_join and summarize missing values
naniar::miss_var_summary(linked_data)

#-------------------------------------------------------------------------------

# Generate quintile range of income for urban areas
##  Level of Geography (L.O.G.): 61 = Area: Census Tract

urban_index <- linked_data %>%
  group_by(`year`) %>%
  filter(key_4 %in% (1:3000)) %>% # key_4 for geo level 61 denotes census tracts (urban regions)
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# check whether data has NA's after left_join and summarize missing values
naniar::miss_var_summary(urban_index)

# clean up the urban_index table and save
drop.cols <- c("key_1", "key_2", "key_3")
urban_index %>%
  select(-one_of(drop.cols)) %>%
  write_csv(here::here("output-data", "urban-index.csv"))

#-------------------------------------------------------------------------------

# Generate quintile range of income for rural areas (composite)

## Level of Geography (L.O.G.): 09 = Postal Area: Rural Communities (Not in City)

rural_rc <- linked_data %>%
  group_by(`year`) %>%
  filter(key_3 %in% (3001:6000)) %>%
  drop_na(studyid) %>%
  ungroup()

# check duplicates in `postal|area`
rural_rc %>%
  filter(year == 2015)

# check whether data has NA's after left_join and summarize missing values
naniar::miss_var_summary(rural_rc)


## Level of Geography (L.O.G.): 06 = Postal Area: Rural Postal Code Areas (Within City)

rural_rpc <- linked_data %>%
  group_by(`year`) %>%
  filter(key_2 %in% (6001:9000)) %>%
  drop_na(studyid) %>%
  ungroup()

# check whether data has NA's after left_join and summarize missing values
naniar::miss_var_summary(rural_rpc)


# check whether postal|area's in rural_index_rpc and rural_index_rc differ
# Yes, some are different
all(rural_rpc$`postal|area` == rural_rc$`postal|area`)
rural_rpc$`postal|area`[!(rural_rpc$`postal|area` %in% rural_rc$`postal|area`)]

# merge rural geographies in data together and generate quintile range for total income
rural_index <- full_join(rural_rpc, rural_rc) %>%
  group_by(`year`) %>%
  mutate(UQs = ntile(`total|income|median|total`, 5)) %>%
  distinct(`level|of|geo`, `postal|area`, studyid, .keep_all = TRUE) # remove duplicated postal codes

# check whether data has NA's after left_join and summarize missing values
naniar::miss_var_summary(rural_index)

# clean out additional columns
drop.cols <- c("key_1", "key_4")
rural_index <- rural_index %>% select(-one_of(drop.cols))


# remove NA's in the studyid column and export as csv
rural_index %>%
  write_csv(here::here("output-data", "rural-index.csv"))

#-------------------------------------------------------------------------------

# Combine rural and urban indices and output one csv for linked data
rural <- fread(here::here("output-data", "rural-index.csv"))
urban <- fread(here::here("output-data", "urban-index.csv"))

bc_indices <- plyr::rbind.fill(rural, urban) %>%
  write_csv(here::here("output-data", "bc-index.csv"))

#-------------------------------------------------------------------------------

# Check bc index data and proceed with analysis
bc <- fread(here::here("output-data", "bc-index.csv"))

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# In the case that postal geographies do not fall into urban or rural designations,
# we can take CD as they cover all of BC

## Level of Geography (L.O.G.): 21 = Area: Census Division
census_division_index <- linked_data %>%
  group_by(`year`) %>%
  filter(key_1 %in% (9001:12000)) %>%
  mutate(RQ_cd =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# remove NA's in the studyid column and export as csv
census_division_index %>%
  write_csv(here::here("output-data", "census_division_index.csv"))



