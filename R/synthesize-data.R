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



## Install Packages/dependencies

packages <- c("synthpop", "tidyverse", "data.table", "here")
lapply(packages, library, character.only = TRUE)

#-------------------------------------------------------------------------------

## Here we sunthesiste a dataset using default data in synthpop library
# SD2011 is an example data in synthpop library
list_cols <- colnames(SD2011)
synthesize <- SD2011[, list_cols]

# generate synthetic data with studyids
synthesize$studyid <- paste0("s", sample(100000000:200000000, 5000, replace=TRUE))

# re-arrange column names so that studyid is the first collumn
synthesize <- synthesize[,c(36, 2:35)]

# generate unlinked studyids in a sample of data
synthesize_rep <- sample_n(synthesize, 2000, replace = TRUE) %>%
  mutate(studyid = str_replace_all(studyid, "s","u"))

# bind tables with linked and unlinked studyids
data <- rbind(synthesize, synthesize_rep)

#-------------------------------------------------------------------------------

## Generate random dates to resemble DIP data
data$date <- sample(seq(as.Date('2000/01/01'), as.Date('2015/01/01'), by="day"), 7000, replace = TRUE)

#-------------------------------------------------------------------------------

## Generate random concepts based on IND_1 master file
tax_data <- fread(here::here("input-data", "1_IND.csv"))

# select the postal codes merge with data
postal_concept <- tax_data %>%
  select(`postal|area`, `level|of|geo`) %>%
  distinct(`postal|area`, `level|of|geo`) %>%
  sample_n(7000, replace = TRUE)

# add selected postal codes to data
data <- cbind(postal_concept, data)

#-------------------------------------------------------------------------------

# Primary/linkage key generation to enable data linkage
# 1. Generate a walk key for urban areas (CT's or geo level = 61) to allow linkage with tax data
nrow_ct <- data %>%
  filter(`level|of|geo` == 61) %>%
  tally() # repeat steps above until nrow_ct$n is less than 3000

walk_key_ct <- as.data.frame(sample(1:3000, size =nrow_ct$n, replace=FALSE))
colnames(walk_key_ct)[1] <- "walk_ct"

# generate new data for ct's
ct_data <- data %>%
  filter(`level|of|geo` == 61) %>%
  mutate(ct_walk = walk_key_ct$walk_ct)


# 2. Generate a walk key for rural areas (geo level = 6/9) to allow linkage with tax data
## Level of Geography (L.O.G.): 09 = Postal Area: Rural Communities (Not in City)
nrow_rc <- data %>%
  filter(`level|of|geo` == 9) %>%
  tally()


walk_key_rc <- as.data.frame(sample(3001:6000, size =nrow_rc$n, replace=FALSE))
colnames(walk_key_rc)[1] <- "walk_rc"

# generate new data for rc's
rc_data <- data %>%
  filter(`level|of|geo` == 9) %>%
  mutate(rc_walk = walk_key_rc$walk_rc)


## Level of Geography (L.O.G.): 06 = Postal Area: Rural Postal Code Areas (Within City)
nrow_rpc <- data %>%
  filter(`level|of|geo` == 6) %>%
  tally()

walk_key_rpc <- as.data.frame(sample(6001:9000, size =nrow_rpc$n, replace=FALSE))
colnames(walk_key_rpc)[1] <- "walk_rpc"

# generate new data for rpc's
rpc_data <- data %>%
  filter(`level|of|geo` == 6) %>%
  mutate(rpc_walk = walk_key_rpc$walk_rpc)


# 3. Generate a walk key for census divisions (geo level = 21) to allow linkage with tax data
# this level will be used if postal codes don't fall in urban or rural areas
## Level of Geography (L.O.G.): 21 = Area: Census Division
nrow_cd <- data %>%
  filter(`level|of|geo` == 21) %>%
  tally()

walk_key_cd <- as.data.frame(sample(9001:12000, size =nrow_cd$n, replace=FALSE))
colnames(walk_key_cd)[1] <- "walk_cd"

# generate new data for cd's
cd_data <- data %>%
  filter(`level|of|geo` == 21) %>%
  mutate(cd_walk = walk_key_cd$walk_cd)

#-------------------------------------------------------------------------------

# merge all geograaphical concepts together
merged_data <- plyr::rbind.fill(data, cd_data, rpc_data, rc_data, ct_data)

#-------------------------------------------------------------------------------

# fix colnames before output
# replace key_1 for cd's, key_2 for rpc's, key_3 for rc's, and key_4 for ct's
colnames(merged_data)[39:42] <- c("key_1", "key_2", "key_3", "key_4")
colnames(merged_data)[1:2] <- c("postal|area", "level|of|geo")

# write out the data table
write_csv(merged_data, here::here("input-data", "synthetic-data.csv"))

