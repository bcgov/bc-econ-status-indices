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

#-------------------------------------------------------------------------------

# download shp files from statscan
## https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-eng.cfm
## e.g. for shp files for census tracts, download: https://www12.statcan.gc.ca/census-recensement/alternative_alternatif.cfm?l=eng&dispext=zip&teng=lct_000a16a_e.zip&k=%20%20%20%20%207190&loc=http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lct_000a16a_e.zip

## set the map colors:
pal_ct <- colorRampPalette(brewer.pal(9, "BrBG"))
pal_cd <- colorRampPalette(brewer.pal(9, "YlOrBr"))
pal_csd <- colorRampPalette(brewer.pal(9, "Set3"))
pal_fsa <- colorRampPalette(brewer.pal(9, "Pastel1"))

# exploring 2016 census tracts (ct):

ct <- sf::st_read("shp-files/lct_000a16a_e.shp") %>%
  dplyr::filter(PRNAME == "British Columbia / Colombie-Britannique") %>%
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

#-------------------------------------------------------------------------------

# exploring pccf data to convert CTs to postal codes

pccf <- fread(here::here("input-data", "PCCF_2013_CT_conversion.csv"))
ind_1 <- fread(here::here("input-data", "1_IND.csv"))

## statcan data
# check whether there are duplicated postal areas in ind_1 table per year
ind_1_ct <- ind_1 %>%
  dplyr::filter(`level|of|geo` == 61) %>%
  dplyr::filter(`year` == 2013) %>%
  dplyr::mutate(CT = `postal|area`)

# check for duplicates
duplicated(ind_1_ct$`postal|area`) # no duplicates!
duplicated(ind_1_ct$CT)

# create a new column for census tracts if they are not rounded
# ind_1_subset <- ind_1 %>%
#  dplyr::filter(`level|of|geo` == 61) %>%
#  dplyr::mutate(CT = formatC(as.numeric(`postal|area`), format="f", digits=2))


## pccf data
# read pccf and select CT geos as character type
# concatenate SAC and CTname to get to CT
revtrunc <- function(x) { x - floor(x) }

pccf_ct_construction <- pccf %>%
  select(SAC, CTname) %>%
  mutate(CTname_extraction = revtrunc(CTname)) %>%
  mutate(CTnam_digit_repair1 = round(as.numeric(CTname, 4))) %>%
  mutate(CTnam_digit_repair2 = formatC(as.numeric(CTnam_digit_repair1), width = 4, flag = '0')) %>%
  mutate(SAC_new = formatC(as.numeric(SAC), width = 3, flag = '0'))


pccf_ct_construction$CT <- paste0(pccf_ct_construction$SAC_new,pccf_ct_construction$CTnam_digit_repair2, pccf_ct_construction$CTname_extraction)

pccf_ct_construction$CT2 <- formatC(as.numeric(pccf_ct_construction$CT), format="f", digits=2)

s#-------------------------------------------------------------------------------

# optional: write table output
# write_csv(pccf, here("pccf-data", "PCCF_2013_CT_conversion.csv"))

pccf_ct_subset <- pccf %>%
  dplyr::select(PostalCode, CT) %>%
  dplyr::mutate(CT = as.character(CT))

# check for duplicates
duplicated(pccf_ct_subset$CT)
duplicated(pccf_ct_subset$PostalCode)

# combine pccf and ind_1 tables based on CTs to get postal codes
ind_pccf <- inner_join(ind_1_ct, pccf_ct_subset, by = "CT")
View(ind_pccf)
duplicated(ind_pccf$CT)

# combine file to get CTs for all ind_1 table
## (another way in case the memory fails for above code)
Sys.setenv(R_MAX_VSIZE = 16e9)
Sys.getenv('R_MAX_VSIZE')
ind_pccf_ind <- merge(ind_1, ind_pccf)


# Remove duplicated rows based on common CTs
ind_pccf %>% distinct(CT, .keep_all = TRUE)


#-------------------------------------------------------------------------------

# create a new column for CD:census division (geo level 21)
ind_1_cd <- ind_1 %>%
  dplyr::filter(`level|of|geo` == 21) %>%
  dplyr::filter(`year` == 2013)


# CDs are 6 digits: 2 first digits = Province, 2 next digits = Economic Region, 2 last digits = Census Division
pccf_cd_subset <- pccf %>%
  dplyr::select(PR, ER, CDuid) %>%
  dplyr::mutate(CDuid = stringr::str_sub(as.numeric(CDuid), -2, -1)) %>%
  dplyr::mutate(CD = paste0(pccf$PR,pccf$ER, pccf$CDuid))

#-------------------------------------------------------------------------------

# create a new column for rural postal area codes (geo level 6)
ind_1_rpc <- ind_1 %>%
  dplyr::filter(`level|of|geo` == 6) %>%
  dplyr::filter(`year` == 2013)

#-------------------------------------------------------------------------------

# create a new column for rural communities (geo level 9)
ind_1_rc <- ind_1 %>%
  dplyr::filter(`level|of|geo` == 9) %>%
  dplyr::filter(`year` == 2013)

