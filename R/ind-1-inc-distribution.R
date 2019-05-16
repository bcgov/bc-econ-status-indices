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
ind_1_bc <- ind_1 %>%
  filter(`level|of|geo|` == 9 | `level|of|geo|` == 61 | `level|of|geo|` == 6 | `level|of|geo|` == 21) %>%
  select(`year`, `level|of|geo|`, `place|me|geo|`, `total|income|median|total`, `taxfilers|#|`) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"QU<c9>BEC","Québec")) %>%
  mutate(`place|me|geo|` = str_to_title(`place|me|geo|`)) %>%
  rename("YEAR" =`year`, "GEO" = `level|of|geo|`, "GEO_NAME" = `place|me|geo|`, "MED_INCOME" = `total|income|median|total`, "TAXFILERS" = `taxfilers|#|`)

print(glimpse(ind_1_bc))

#-------------------------------------------------------------------------------

# build shiny app skeleton

ui <- fluidPage(

  # Sidebar layout with a input and output definitions
  sidebarLayout(

    # Inputs
    sidebarPanel(
      textInput("title", "Title", "Individual's Income Distribution in BC"),

      # Select variable for x-axis
      selectInput(inputId = "x",
                  label = "X-axis:",
                  choices = "GEO",
                  selected = "9"),

      # Select variable for y-axis
      selectInput(inputId = "y",
                  label = "Y-axis:",
                  choices = c("TAXFILERS", "MED_INCOME"),
                  selected = "TAXFILERS"),
      # Add a slider selector for years to filter
      sliderInput("years", "Years",
                  min(ind_1_bc$YEAR), max(ind_1_bc$YEAR),
                  value = c(2000, 2015),
                  step = 1)
    ),

    # Outputs
    mainPanel(
      plotOutput(outputId = "boxplot",  hover = "plot_hover", width = 800, height = 400),
      dataTableOutput(outputId = "incometable")
    )
  )
)




server <- function(input, output) {
  # Create scatterplot object the plotOutput function is expecting
  output$boxplot <- renderPlot({

    data <- subset(ind_1_bc,
                   YEAR >= input$years[1] & YEAR <= input$years[2])


    ggplot(data = data, aes_string(x = input$x, y = input$y)) +
      geom_boxplot(fill = "#4271AE", colour = "#1F3552",
                   alpha = 0.7) +
      theme(axis.text.x = element_text(angle = 90))
  })

  # Print data table
  output$incometable <- DT::renderDataTable({

    data <- subset(ind_1_bc,
                   YEAR >= input$years[1] & YEAR <= input$years[2])

    DT::datatable(data = data,
                  options = list(pageLength = 13),
                  rownames = FALSE)

  })

}

# Create a Shiny app object
shinyApp(ui = ui, server = server)



