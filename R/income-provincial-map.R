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
ind_1 <- fread(here("input-data", "1_IND.csv"))
ind_1_df <- ind_1 %>%
  filter(`level|of|geo|` == "11") %>%
  filter(`year` == "2000") %>%
  select(`year`, `place|me|geo|`, `total|income|median|total`) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"QU<c9>BEC","Québec")) %>%
  mutate(`place|me|geo|` = str_to_title(`place|me|geo|`)) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"Newfoundland", "Newfoundland and Labrador")) %>%
  rename("YEAR" =`year`, "GEO" = `place|me|geo|`, "INCOME" = `total|income|median|total`)

print(glimpse(ind_1_df))

#-------------------------------------------------------------------------------

ind_1_df_females <- ind_1 %>%
  filter(`level|of|geo|` == "11") %>%
  filter(`year` == "2000") %>%
  select(`year`, `place|me|geo|`, `total|income|median|females`) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"QU<c9>BEC","Québec")) %>%
  mutate(`place|me|geo|` = str_to_title(`place|me|geo|`)) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"Newfoundland", "Newfoundland and Labrador")) %>%
  rename("YEAR" =`year`, "GEO" = `place|me|geo|`, "INCOME" = `total|income|median|females`)

print(glimpse(ind_1_df_females))

#-------------------------------------------------------------------------------

ind_1_df_males <- ind_1 %>%
  filter(`level|of|geo|` == "11") %>%
  filter(`year` == "2000") %>%
  select(`year`, `place|me|geo|`, `total|income|median|males`) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"QU<c9>BEC","Québec")) %>%
  mutate(`place|me|geo|` = str_to_title(`place|me|geo|`)) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"Newfoundland", "Newfoundland and Labrador")) %>%
  rename("YEAR" =`year`, "GEO" = `place|me|geo|`, "INCOME" = `total|income|median|males`)

print(glimpse(ind_1_df_males))

#-------------------------------------------------------------------------------

# If the .shp files (provinces) aren't already downloaded on your system, this command downloads them
if (!file.exists("./polygons/ne_50m_admin_1_states_provinces_lakes/ne_50m_admin_1_states_provinces_lakes.dbf")){
  download.file(file.path('http://www.naturalearthdata.com/http/',
                          'www.naturalearthdata.com/download/50m/cultural',
                          'ne_50m_admin_1_states_provinces_lakes.zip'),
                f <- tempfile())
  unzip(f, exdir = "./polygons/ne_50m_admin_1_states_provinces_lakes")
  rm(f)
}

# Read the .shp files
provinces <- readOGR("./polygons/ne_50m_admin_1_states_provinces_lakes", 'ne_50m_admin_1_states_provinces_lakes', encoding='UTF-8')


provinces2  <- sp::merge(
  provinces,
  ind_1_df,
  by.x = "name",
  by.y = "GEO",
  sort = FALSE,
  incomparables = NULL,
  duplicateGeoms = TRUE
)

#-------------------------------------------------------------------------------

# explore provinces2 data
summary(provinces2$INCOME)
# subset shp to include only zip codes in the top quartile of mean income
provinces2_inc <- provinces2[!is.na(provinces2$INCOME) & provinces2$INCOME > 55917,]
# map the boundaries of the zip codes in the top quartile of mean income
provinces2_inc %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons()



# create color palette with colorNumeric()
nc_pal <- colorNumeric("YlGn", domain = provinces2_inc@data$INCOME)

provinces2_inc %>%
  leaflet() %>%
  addTiles() %>%
  # set boundary thickness to 1 and color polygons
  addPolygons(weight = 1, color = ~nc_pal(INCOME),
              # add labels that display mean income
              label = ~paste0("Median Income: ", dollar(INCOME)),
              # highlight polygons on hover
              highlightOptions = highlightOptions(weight = 5, color = "white",
                                                  bringToFront = TRUE))

# Create a logged version of the nc_pal color palette
nc_pal <- colorNumeric("YlGn", domain = log(high_inc@data$mean_income))

# apply the nc_pal
high_inc %>%
  leaflet() %>%
  #addProviderTiles("CartoDB") %>%
  addPolygons(weight = 1, color = ~nc_pal(log(mean_income)), fillOpacity = 1,
              label = ~paste0("Mean Income: ", dollar(mean_income)),
              highlightOptions = highlightOptions(weight = 5, color = "white", bringToFront = TRUE))


#-------------------------------------------------------------------------------
provinces2_females  <- sp::merge(
  provinces,
  ind_1_df_females,
  by.x = "name",
  by.y = "GEO",
  sort = FALSE,
  incomparables = NULL,
  duplicateGeoms = TRUE
)


provinces2_males  <- sp::merge(
  provinces,
  ind_1_df_males,
  by.x = "name",
  by.y = "GEO",
  sort = FALSE,
  incomparables = NULL,
  duplicateGeoms = TRUE
)


clear <- "#F2EFE9"
lineColor <- "#000000"
hoverColor <- "red"
lineWeight <- 0.5

pal <- colorNumeric(palette = 'Purples', c(max(ind_1_df_males$INCOME), min(ind_1_df_females$INCOME)), reverse = FALSE)
#pal1 <- colorNumeric(palette = 'Purples', c(max(ind_1_df$INCOME), min(ind_1_df$INCOME)), reverse = FALSE)
#pal2 <- colorNumeric(palette = 'Blues', c(max(ind_1_df_males$INCOME), min(ind_1_df_males$INCOME)), reverse = FALSE)
#pal3 <- colorNumeric(palette = 'Reds', c(max(ind_1_df_females$INCOME), min(ind_1_df_females$INCOME)), reverse = FALSE)

provinces2 %>%
  leaflet() %>%
  leaflet(options = leafletOptions(zoomControl = FALSE,
                                   minZoom = 3, maxZoom = 3,
                                   dragging = FALSE)) %>%
  addTiles() %>%
  setView(-110.09, 62.7,  zoom = 3) %>%
  addPolygons(data = subset(provinces2, name %in% c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Québec", "New Brunswick", "Prince Edward Island", "Nova Scotia", "Newfoundland and Labrador", "Yukon", "Northwest Territories", "Nunavut")),
              fillColor = ~ pal(INCOME),
              fillOpacity = 0.5,
              stroke = TRUE,
              weight = lineWeight,
              color = lineColor,
              highlightOptions = highlightOptions(fillOpacity = 1, bringToFront = TRUE, sendToBack = TRUE),
              label=~stringr::str_c(
                name,' ',
                formatC(INCOME)),
              labelOptions= labelOptions(direction = 'auto'),
              group = "Both") %>%

  addPolygons(data = subset(provinces2_males, name %in% c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Québec", "New Brunswick", "Prince Edward Island", "Nova Scotia", "Newfoundland and Labrador", "Yukon", "Northwest Territories", "Nunavut")),
              fillColor = ~ pal(INCOME),
              fillOpacity = 0.5,
              stroke = TRUE,
              weight = lineWeight,
              color = lineColor,
              highlightOptions = highlightOptions(fillOpacity = 1, bringToFront = TRUE, sendToBack = TRUE),
              label=~stringr::str_c(
                name,' ',
                formatC(INCOME)),
              labelOptions= labelOptions(direction = 'auto'),
              group = "Males") %>%


  addPolygons(data = subset(provinces2_females, name %in% c("British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Québec", "New Brunswick", "Prince Edward Island", "Nova Scotia", "Newfoundland and Labrador", "Yukon", "Northwest Territories", "Nunavut")),
              fillColor = ~ pal(INCOME),
              fillOpacity = 0.5,
              stroke = TRUE,
              weight = lineWeight,
              color = lineColor,
              highlightOptions = highlightOptions(fillOpacity = 1, bringToFront = TRUE, sendToBack = TRUE),
              label=~stringr::str_c(
                name,' ',
                formatC(INCOME)),
              labelOptions= labelOptions(direction = 'auto'),
              group = "Females") %>%

  # Add the checklist
  addLayersControl(overlayGroups = c('Males', 'Females', 'Both'),
                   options = layersControlOptions(collapsed = FALSE),
                   position = 'topright') %>%
  addLegend(pal = pal,
            values = ind_1_df$INCOME,
            position = "bottomleft",
            title = "Total Median Income",
            labFormat = labelFormat(suffix = "", transform = function(x) sort(x, decreasing = FALSE))
  ) %>%

  addLayersControl(
    position = "topleft",
    baseGroups = c("Males", "Females", "Both"),
    #overlayGroups = c("sfbdjsd", "sdbjskfdk"),
    options = layersControlOptions(collapsed = FALSE)
  )




