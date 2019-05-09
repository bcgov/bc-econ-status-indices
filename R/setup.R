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
library(bcdata)
library(leaflet)
library(rgdal)
library(stringr)
library(shiny)

#-------------------------------------------------------------------------------

## Object to source setup script

.setup_sourced <- TRUE
