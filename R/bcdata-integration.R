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

# read in the csv
ind_1 <- fread(here("input-data", "1_IND.csv"))
ind_1_data <- ind_1 %>%
  select(`taxfilers|#|`,`level|of|geo|`, `place|me|geo|`, `postal|area|`) %>%
  filter(ind_1$`level|of|geo|` != 11 & ind_1$`level|of|geo|` != 12)

#post_area <- ind_1_data %>%
  #mutate(`postal|area|` = str_extract(`postal|area|`, "^5"))

#-------------------------------------------------------------------------------

# browse the bcdc to find geographical concepts
# missing CA, RURC

bcdata::bcdc_browse()

bcdata::bcdc_search("census")

# Current Census Subdivision Boundaries
CSD <- bcdata::bcdc_get_data("4c5618c6-38dd-4a62-a3de-9408b4974bb6")
mapview(CSD)

# Census Tracts
CT <- bcdata::bcdc_get_data("539aae5b-12f6-4934-9592-9b27acc827f8")
mapview(CT)

# Current Census Metropolitan Areas (other, wms, kml)
CMA <- bcdata::bcdc_get_data("a6fb34b7-0937-4718-8f1f-43dba2c0f407")
mapview(CMA)

# Current Census Division Boundaries (other, wms, kml)
CD <- bcdata::bcdc_get_data("ef17918a-597a-4012-8534-f8e71d8735b3")
mapview(CD)

#-------------------------------------------------------------------------------

bcdata::bcdc_search("federal")

# Federal Electoral Districts of Canada (xlsx)
FED <- bcdata::bcdc_get_data("3d520a7-e1f5-4fde-83e7-c7974430fb40")
mapview(FED)

#-------------------------------------------------------------------------------

bcdata::bcdc_search("economic region")

# Current Census Economic Regions (other, wms, kml)
ER <- bcdata::bcdc_get_data("1aebc451-a41c-496f-8b18-6f414cde93b7")
mapview(ER)

#-------------------------------------------------------------------------------




