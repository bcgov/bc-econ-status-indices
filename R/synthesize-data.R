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

## Generate random date and times!
# set start and end dates to sample between
day.start <- "2000/01/01"
day.end <- "2015/12/31"

# Define a random date/time selection function
rand.day.time <- function(day.start,day.end,size) {
  dayseq <- seq.Date(as.Date(day.start),as.Date(day.end),by="day")
  dayselect <- sample(dayseq,size,replace=TRUE)
  hourselect <- sample(1:24,size,replace=TRUE)
  minselect <- sample(0:59,size,replace=TRUE)
  as.POSIXlt(paste(dayselect, hourselect,":",minselect,sep="") )
}

data$time <- rand.day.time(day.start,day.end,size=7000)

#-------------------------------------------------------------------------------

## Add additional attributes to the data (e.g. geo concepts)
# Add geographic levels to a column in the data
geo <- c("3", "6", "7", "8", "9", "10", "11", "12", "21",
         "31", "41", "51", "61", "42")

# fill geos to the length of columns in data
data$geo <- rep(geo, 500)

#-------------------------------------------------------------------------------

## Generate random postal codes from IND_1 master file
tax_data <- fread(here::here("input-data", "1_IND.csv"))

# select the postal codes merge with data
PostalCode <- tax_data %>%
  select(`postal|area`) %>%
  distinct(`postal|area`) %>%
  sample_n(7000, replace = TRUE)

# add selected postal codes to data
data <- cbind(PostalCode, data)

#-------------------------------------------------------------------------------
# write out the data table
write_csv(data, here::here("input-data", "synthetic-data.csv"))

