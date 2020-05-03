#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
#library(shinyalert)

# Define UI for application that draws a histogram
shinyUI(fluidPage(


  # Application title
  titlePanel("Word Master World Series"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      radioButtons(inputId = "role", "Select a role:",
                   choices = c("I am a word master." = 'master',
                               "I am a player." = 'player',
                               "Submit words for a new game." = 'pregame'),
                   selected = 'player'),
      
      
    ),
  
    
    # Show a plot of the generated distribution
    mainPanel(
        
       
    )#end of mainPanel
)#end of sidebar layout
)#end of fluidpage
)#end of shinyUI
