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
library(shinyalert)

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
      
      conditionalPanel(
        condition = "input.role == 'master'",
        
        textInput("who", "Reveal the identity of the word:", ""),
        useShinyalert(),
        actionButton("reveal", "Go/Reveal"), 
        actionButton("erase", "Erase Game")
      ),
      
      conditionalPanel(
        condition = "input.role == 'player'",
        
        actionButton("refresh", "Refresh the Game")
      ),
      
      conditionalPanel(
        condition = "input.role == 'pregame'",

        textInput("word", HTML("Word Submission Box<br>(One word a time please)"), ""),
        useShinyalert(),
        actionButton("submit", "Submit")
        #actionButton("view", "View Game")
      )
    ),
  
    
    # Show a plot of the generated distribution
    mainPanel(
        conditionalPanel(
          condition = "input.role == 'player'",
          
          htmlOutput("infoToPlayer"),
          DT::dataTableOutput("GameTablePlayerCopy")
        ),#end of conditionalPanal
        conditionalPanel(
          condition = "input.role == 'master'",
          
          tabsetPanel(id = 'Home',
            tabPanel("Security Window", 
                   htmlOutput("infoToSecurityWindow")
            ),#end of tabPanel
            tabPanel("Master Window",
                     htmlOutput("infoToMaster1"),
                     DT::dataTableOutput("GameTableMaster"),
                     htmlOutput("infoToMaster2"),
                     DT::dataTableOutput("GameTablePlayer")
            )#end of tabPanel
        )#end of nvabarPage
        )#end of conditionalPanal
       
    )#end of mainPanel
)#end of sidebar layout
)#end of fluidpage
)#end of shinyUI
