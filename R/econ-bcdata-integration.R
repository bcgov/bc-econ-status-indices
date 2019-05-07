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


remotes::install_github("bcgov/bcdata")
library(bcdata)

# browse the bcdc to find geographical concepts
bcdata::bcdc_browse()

bcdata::bcdc_search("census")
bcdata::bcdc_get_data("census")

census_sub <- bcdata::bcdc_get_data("4c5618c6-38dd-4a62-a3de-9408b4974bb6")
max.plot(census_sub)
