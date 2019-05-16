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

# Read and clean the data
ind_5C <- fread(here("input-data", "5C_IND.csv"))

ind_5C_bc <- ind_5C %>%
  filter(`level|of|geo|` == 9 | `level|of|geo|` == 61 | `level|of|geo|` == 6 | `level|of|geo|` == 21) %>%
  mutate(`place|me|` = str_replace_all(`place|me|`,"QU<c9>BEC","Québec")) %>%
  mutate(`place|me|` = str_to_title(`place|me|`))

print(glimpse(ind_5C_bc))
