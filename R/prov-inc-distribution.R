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
ind_1_prov <- ind_1 %>%
  filter(`level|of|geo|` == 11) %>%
  select(`year`, `level|of|geo|`, `place|me|geo|`, `total|income|median|total`, `total|income|median|males`, `total|income|median|females`, `taxfilers|average|age`) %>%
  mutate(`place|me|geo|` = str_replace_all(`place|me|geo|`,"QU<c9>BEC","Québec")) %>%
  mutate(`place|me|geo|` = str_to_title(`place|me|geo|`)) %>%
  rename("YEAR" =`year`, "GEO" = `level|of|geo|`, "GEO_NAME" = `place|me|geo|`, "MED_INCOME" = `total|income|median|total`, "MED_INCOME_MALES" = `total|income|median|males`, "MED_INCOME_FEMALES" = `total|income|median|females`, "AVG_AGE" = `taxfilers|average|age`)

print(glimpse(ind_1_prov))

#-------------------------------------------------------------------------------

# build shiny app skeleton

ui <- fluidPage(

  # Sidebar layout with a input and output definitions
  sidebarLayout(

    # Inputs
    sidebarPanel(
      textInput("title", "Title", "Individual's Income Distribution"),

      # Select variable for x-axis
      selectInput(inputId = "x",
                  label = "X-axis:",
                  choices = "GEO_NAME",
                  selected = "British Columbia"),

      # Select variable for y-axis
      selectInput(inputId = "y",
                  label = "Y-axis:",
                  choices = c("MED_INCOME", "MED_INCOME_MALES", "MED_INCOME_FEMALES", "AVG_AGE"),
                  selected = "MED_INCOME"),
      # Add a slider selector for years to filter
      sliderInput("years", "Years",
                  min(ind_1_prov$YEAR), max(ind_1_prov$YEAR),
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

    data <- subset(ind_1_prov,
                     YEAR >= input$years[1] & YEAR <= input$years[2])


    ggplot(data = data, aes_string(x = input$x, y = input$y)) +
      geom_boxplot(fill = "#4271AE", colour = "#1F3552",
                   alpha = 0.7) +
      theme(axis.text.x = element_text(angle = 90))
    })

    # Print data table
    output$incometable <- DT::renderDataTable({

      data <- subset(ind_1_prov,
                     YEAR >= input$years[1] & YEAR <= input$years[2])

      DT::datatable(data = data,
                    options = list(pageLength = 13),
                                   rownames = FALSE)

    })

  }

# Create a Shiny app object
shinyApp(ui = ui, server = server)



