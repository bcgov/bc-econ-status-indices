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
## merge tax data and synthetic data tables

synthetic_data_linkage <- synthetic_data %>%
  select(studyid, `postal|area`)

tax_data_linkage <- tax_data %>%
  select(`year`, `postal|area`, `level|of|geo`, `place|name|geo`, `total|income|median|total`)

linked_data <- left_join(tax_data_linkage, synthetic_data_linkage, by = "postal|area")

# check whether data has NA's after left_join
naniar::miss_var_summary(linked_data)

#-------------------------------------------------------------------------------

# Generate quintile range of income for urban areas
##  Level of Geography (L.O.G.): 61 = Area: Census Tract

urban_index <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 61) %>% # geo level 61 denotes census tracts (urban regions)
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# remove NA's in the studyid column
urban_index %>%
  drop_na(studyid)


#-------------------------------------------------------------------------------

# Generate quintile range of income for rural areas (composite)

## Level of Geography (L.O.G.): 09 = Postal Area: Rural Communities (Not in City)

rural_index_rc <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 9) %>%
  mutate(RQ_a =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

## Level of Geography (L.O.G.): 06 = Postal Area: Rural Postal Code Areas (Within City)

rural_index_rpc <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` ==  6) %>%
  mutate(RQ_b =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

## Level of Geography (L.O.G.): 21 = Area: Census Division
rural_index_cd <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 21) %>%
  mutate(RQ_c =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# check duplicates in `postal|area`
rural_index_rc %>%
  filter(year == 2015)


# merge indices together and drop NA's in studyid column
rural_index <- plyr::rbind.fill(rural_index_rc, rural_index_rpc, rural_index_cd, rural_index_cd) %>%
  mutate(RQs = c(na.omit(RQ_a),na.omit(RQ_b), na.omit(RQ_c))) %>%
  drop_na(studyid)

# clean out additional columns
drop.cols <- c("RQ_a", "RQ_b", "RQ_c")
rural_index <- rural_index %>% select(-one_of(drop.cols))


