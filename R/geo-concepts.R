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


if (!exists(".setup_sourced")) source(here::here("R/setup.R"))
pal_ct <- colorRampPalette(brewer.pal(9, "BrBG"))
pal_cd <- colorRampPalette(brewer.pal(9, "YlOrBr"))
pal_csd <- colorRampPalette(brewer.pal(9, "Set3"))
pal_fsa <- colorRampPalette(brewer.pal(9, "Pastel1"))

#-------------------------------------------------------------------------------

# download shp files from statscan
## https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm
## e.g. for shp files for census tracts, download: https://www12.statcan.gc.ca/census-recensement/alternative_alternatif.cfm?l=eng&dispext=zip&teng=lct_000a16a_e.zip&k=%20%20%20%20%207190&loc=http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lct_000a16a_e.zip

# exploring 2016 census tracts (ct):

ct <- read_sf(here("shp-files", "lct_000a16a_e.shp")) %>%
  filter(PRNAME == "British Columbia / Colombie-Britannique") %>%
  st_transform(3005)

# plot/map ct's

plot(ct)

mapview(ct, col.regions = pal_ct(100))

ggplot2::ggplot() +
  geom_sf(data = bc_neighbours(), fill = NA) +
  geom_sf(data = ct, aes(fill = CMANAME))

#-------------------------------------------------------------------------------

# exploring 2016 census division (cd):

cd <- read_sf(here("shp-files", "lcd_000a16a_e.shp")) %>%
  filter(PRNAME == "British Columbia / Colombie-Britannique") %>%
  st_transform(3005)

# plot/map cd's

plot(cd)

mapview(cd, col.regions = pal_cd(100))

ggplot2::ggplot() +
  geom_sf(data = bc_neighbours(), fill = NA) +
  geom_sf(data = cd, aes(fill = CDNAME))

#-------------------------------------------------------------------------------

# exploring 2016 census subdivision (csd):

csd <- read_sf(here("shp-files", "lcsd000a16a_e.shp")) %>%
  filter(PRNAME == "British Columbia / Colombie-Britannique") %>%
  st_transform(3005)

# plot/map csd's

plot(csd)

mapview(csd, col.regions = pal_csd(100))

ggplot2::ggplot() +
  geom_sf(data = bc_neighbours(), fill = NA) +
  geom_sf(data = csd, aes(fill = CSDNAME))

#-------------------------------------------------------------------------------

# exploring 2016 forward sortation area (fsa):

fsa <- read_sf(here("shp-files", "lfsa000a16a_e.shp")) %>%
  filter(PRNAME == "British Columbia / Colombie-Britannique") %>%
  st_transform(3005)

# plot/map fsa's

plot(fsa)

mapview(fsa,  col.regions = pal_fsa(100))

ggplot2::ggplot() +
  geom_sf(data = bc_neighbours(), fill = NA) +
  geom_sf(data = fsa, aes(fill = CFSAUID))



# Intersection ------------------------------------------------------------

mapview(list(ct, cd, csd, fsa))

#-------------------------------------------------------------------------------

# overlay maps to find overlaps in geo areas:

mapview(ct, col.regions = pal_ct(100)) + mapview(fsa,  col.regions = pal_fsa(100))
mapview(ct, col.regions = pal_ct(100)) + mapview(cd, col.regions = pal_cd(100))
mapview(fsa, col.regions = pal_fsa(100)) + mapview(cd, col.regions = pal_cd(100))

#-------------------------------------------------------------------------------

# Another platform for exploring provincial geographies
# Use BC data catalogue and keywords for geographical regions of interest
## using bcdata package

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

# Current Census Economic Regions (other, wms, kml)
ER <- bcdata::bcdc_get_data("1aebc451-a41c-496f-8b18-6f414cde93b7")
mapview(ER)
