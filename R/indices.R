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

linked_data <- inner_join(tax_data_linkage, synthetic_data_linkage, by = "postal|area")

#-------------------------------------------------------------------------------

# Generate quintile range of income for urban areas

urban_index <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 61) %>% # geo level 61 denotes census tracts (urban regions)
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

#-------------------------------------------------------------------------------

# Generate quintile range of income for rural areas (composite)

rural_index_rc <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 9) %>% # geo level 9 denotes rural communities
  mutate(RQ_a =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

rural_index_rpc <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` ==  6) %>% # geo level 6 denote rural postal codes
  mutate(RQ_b =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

rural_index_cd <- linked_data %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 21) %>% # geo levels 21 denotes census division
  mutate(RQ_c =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# merge indices together
rural_index <- plyr::rbind.fill(rural_index_rc, rural_index_rpc, rural_index_cd, rural_index_cd) %>%
  mutate(RQs = c(na.omit(RQ_a),na.omit(RQ_b), na.omit(RQ_c)))

# clean out additional columns
drop.cols <- c("RQ_a", "RQ_b", "RQ_c")
rural_index %>% select(-one_of(drop.cols))


