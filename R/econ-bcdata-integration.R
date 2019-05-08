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


# install/load packages and dependencies
library(here)
library(data.table)
library(dplyr)
library(readr)
library(ggplot2)
library(lattice)
library(MASS)
library(tabplot)


# read in the csv
ind_1 <- fread(here("input-data", "1_IND.csv"))

# Levels of geography are:
# 3 (URBAN FSA)
# 6 (RURAL POSTAL CODE AREAS)
# 7 (OTHER URBAN AREAS)
# 8 (CITY TOTAL)
# 9 (RURAL COMMUNITIES)
# 10 (OTHER PROVINCIAL TOTAL)
# 11 (PROVINCE/TERRITORY TOTAL)
# 12 (CANADA)
# 21 (CENSUS DIVISION)
# 31 (FEDERAL ELECTORAL DISTRICT)
# 51 (ECONOMIC REGION)
# 41 (CENSUS METROPOLITAN AREA)
# 42 (CENSUS AGGLOMERATION)
# 61 (CENSUS TRACT)
# More Information: https://www12.statcan.gc.ca/census-recensement/2016/ref/98-304/chap12-eng.cfm


remotes::install_github("bcgov/bcdata")
library(bcdata)

# browse the bcdc to find geographical concepts
bcdata::bcdc_browse()

bcdata::bcdc_search("census")
bcdata::bcdc_get_data("census")

census_sub <- bcdata::bcdc_get_data("4c5618c6-38dd-4a62-a3de-9408b4974bb6")
max.plot(census_sub)
