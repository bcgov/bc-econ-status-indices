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


# package dependencies
library(drake)
library(tidyverse)


# Function to create plot
create_plot <- function(data) {
  ggplot(data, aes(x = height, y = mass, fill = species)) +
    geom_point()
}

# plan for the visualization
plan <- drake_plan(
  synthetic_data = readr::read_csv(file_in("input-data/synthetic-data.csv")),
  tax_data = readr::read_csv(file_in("input-data/1_IND.csv")),
  linked_data = tax_data %>%
    left_join(synthetic_data),
  make_urban_index <- linked_data %>%
    group_by(`year`) %>%
    filter(`level|of|geo` == 61) %>% # geo level 61 denotes census tracts (urban regions)
    mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
    ungroup(),
  make_rural_index <- plyr::rbind.fill(rural_index_rc, rural_index_rpc, rural_index_cd, rural_index_cd) %>%
    mutate(RQs = c(na.omit(RQ_a),na.omit(RQ_b), na.omit(RQ_c))),
  indexed_data =  plyr::rbind.fill(rural, urban) %>%
    write_csv(here::here("output-data", "bc-index.csv"))
)

# Configure the plan and visualize
make(plan)
config <- drake_config(plan)
vis_drake_graph(config)

