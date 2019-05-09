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
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"NEWFOUNDLAND","Newfoundland and Labrador")) %>%
  mutate(`place|me|geo|` = str_to_title(`place|me|geo|`)) %>%
  rename("YEAR" =`year`, "GEO" = `place|me|geo|`, "INCOME" = `total|income|median|total`)

print(glimpse(ind_1_df))

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

clear <- "#F2EFE9"
lineColor <- "#000000"
hoverColor <- "red"
lineWeight <- 0.5

pal <- colorNumeric(palette = 'Reds', c(max(ind_1_df$INCOME), min(ind_1_df$INCOME)), reverse = FALSE)

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
              labelOptions= labelOptions(direction = 'auto')) %>%
  # Add the checklist
  addLegend(pal = pal,
            values = ind_1_df$INCOME,
            position = "bottomleft",
            title = "Median Income",
            labFormat = labelFormat(suffix = ""))

#-------------------------------------------------------------------------------

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                style="z-index:500;", # legend over my map (map z = 400)
                tags$h3("map"),
                sliderInput("period", "Chronology",
                            min(ind_1_df$YEAR),
                            max(ind_1_df$YEAR),
                            value = range(ind_1_df$YEAR),
                            step = 1,
                            sep = ""
                )
  )
)

server <- function(input, output, session) {

  # reactive filtering data from UI

  reactive_data_chrono <- reactive({
    df %>%
      filter(year >= input$periode[1] & YEAR <= input$period[2])
  })


  # static backround map
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles() %>%
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })

  # reactive circles map
  observe({
    leafletProxy("map", data = reactive_data_chrono()) %>%
      clearShapes() %>%
      addMarkers(lng=~lng,
                 lat=~lat,
                 layerId = ~id) # Assigning df id to layerid
  })
}

shinyApp(ui, server)

#-------------------------------------------------------------------------------

#colour by income

# Color by quantile
map= leaflet(provinces)%>% addTiles()  %>% setView(-74.09, 45.7,  zoom = 3) %>%
  addPolygons( stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5, color = ~colorQuantile("YlOrRd", ind_1_df$INCOME)(ind_1_df$INCOME) )
map

# Numeric palette
map=leaflet(provinces)%>% addTiles()  %>% setView(-74.09, 45.7,  zoom = 3) %>%
  addPolygons( stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5, color = ~colorNumeric("YlOrRd", ind_1_df$INCOME)(ind_1_df$INCOME) )
map

# Bin
map=leaflet(provinces)%>% addTiles()  %>% setView(-74.09, 45.7,  zoom = 3) %>%
  addPolygons( stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5, color = ~colorBin("YlOrRd", ind_1_df$INCOME)(ind_1_df$INCOME) )
map
