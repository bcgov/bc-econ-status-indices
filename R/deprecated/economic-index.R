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

#-------------------------------------------------------------------------------

# read in synthetic data
working <- setwd("~/bc-econ-status-indices/input-data")
working <- file.path("~/bc-econ-status-indices/input-data")
list.files(working)

tax <- fread("1_IND.csv")
dip <- read.csv("synthetic-dip-data.csv")

# Urban quintile
# cleanup the tax data
clean_taxdata_u <- tax %>%
  filter(`level|of|geo` == 61) %>%
  select(`level|of|geo`, `total|income|median|total`, `year`, `postal|area`) %>%
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  mutate(year = as.numeric(`year`)) %>%
  mutate(geo = `level|of|geo`) %>%
  mutate(pc = as.factor(`postal|area`)) %>%
  select(UQs, year, geo, pc)


# cleanup the dip data
clean_dipdata_u <- dip %>%
  mutate(date = as.Date(date)) %>%
  mutate(year = as.numeric(format(date, "%Y"))) %>%
  mutate(pc = as.factor(pc)) %>%
  select(studyid, pc, year, geo)


# integrate the two datasets
integrate_dipdata_u <- inner_join(clean_taxdata_u, clean_dipdata_u, by = c("geo", "year", "pc"))

#-------------------------------------------------------------------------------

# Rural Quintile
# cleanup the tax data
clean_taxdata_r <- tax %>%
  filter(`level|of|geo` == 9) %>%
  select(`level|of|geo`, `total|income|median|total`, `year`, `postal|area`) %>%
  mutate(RQs =  ntile(`total|income|median|total`, 5)) %>%
  mutate(year = as.numeric(`year`)) %>%
  mutate(geo = `level|of|geo`) %>%
  mutate(pc = as.factor(`postal|area`)) %>%
  select(RQs, year, geo, pc)


# cleanup the dip data
clean_dipdata_r <- dip %>%
  mutate(date = as.Date(date)) %>%
  mutate(year = as.numeric(format(date, "%Y"))) %>%
  mutate(pc = as.factor(pc)) %>%
  select(studyid, pc, year, geo)

integrate_dipdata_r <- inner_join(clean_taxdata_r, clean_dipdata_r, by = c("geo", "year", "pc"))
