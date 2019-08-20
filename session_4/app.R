# This is an awesome introduction to making a Shiny app: https://deanattali.com/blog/building-shiny-apps-tutorial/

# And here are a bunch of tutorials and examples: https://shiny.rstudio.com/tutorial/

# Here are some cool examples of what you can do with Shiny: https://shiny.rstudio.com/gallery/

# Step 1. Create a new project.
# Step 2. Open a new R Script.
# Step 3. Add the following lines of code:

# library(shiny)
# ui <- fluidPage()
# server <- function(input, output) {}
# shinyApp(ui = ui, server = server)

library(shiny)
ui <- fluidPage(
  titlePanel("I am adding a title!"),
  sidebarLayout(
    sidebarPanel("put my widgets here"),
    mainPanel("put my graph here")
  )
)

server <- function(input, output) {}
shinyApp(ui = ui, server = server)
