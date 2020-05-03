#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
#library(shinyalert)
library(DT)

shinyServer(function(input, output, session) {
  # teamzero <- '#FBDE445F' #Yellow
  # teamone <- '#F650585F'  #Red
  # teamtwo <- '#6495EDFF'   #Blue
  # #teamzero <- '#28334A5F'
  # 
  # receipt <- c(' a simple', ' a tricky',' a brutal', ' a fabulous', ' an insane', ' an interesting', ' a kind')
  # 
  # # Collect words for the game
  # observeEvent(input$submit, {
  #   rmhyphen <- gsub('-', '', input$word)
  #   if (input$word != "" & grepl('[[:punct:]]|[[:space:]]', rmhyphen)){
  #     shinyalert("Sorry!", "No special characters or spaces please :) ", type = "error")
  #   }else if (input$word != "" & !grepl('[[:punct:]]', rmhyphen)){
  #     write.table(input$word, 'WordMaster.csv', append = TRUE, 
  #               col.names = FALSE, row.names = FALSE, 
  #               quote = FALSE, sep = "")
  #   shinyalert(title = paste('Awesome, ', input$word, ' is', sample(receipt, 1),' word.'), type = "success")
  #   updateTextInput(session,"word", "Words Submission Box", "")
  #   }else{
  #     shinyalert("Hmm", "Looks like you forgot to type in a word. ", type = "error")
  #   }
  # })
  # 
  # observeEvent(input$role, {
  #   if (input$role == 'master'){
  #     updateTabsetPanel(session, "Home", "Security Window")
  #     shinyalert("Are you sure you want to control the game as a master? Type 'Master' to proceed.", type = 'input',
  #                callbackR = function(x) { if(x != 'Master'){
  #                   updateRadioButtons(session, 'role',selected = 'player')
  #                 }
  #     })
  #   }
  # })
  # 
  # 
  # 
  # # Erase all existing words
  # observeEvent(input$newgame, {
  #   shinyalert(
  #     "This will erase everything and start a completely new game. Type 'Erase' to proceed.", type = "input",
  #     callbackR = function(x) { if(x == 'Erase') {
  #           close( file( 'WordMaster.csv', open="w" ) )
  #       
  #           # Reset words
  #           write.table("", 'WordMaster.csv', row.names = FALSE, col.names = 'Words', quote = FALSE, sep = ",")
  #           
  #           # Reset status
  #           write.table("new", 'status.csv', row.names = FALSE, col.names = FALSE, quote = FALSE, sep = ",")
  #           
  #           # Reset masterkey
  #           mcpool <- sample(c(rep(teamone, 9), rep(teamtwo, 9), rep(teamzero,11), 'black'))
  #           mcmap <- matrix(mcpool, nrow = 6, byrow = TRUE)
  #           write.csv(mcmap,'masterkey.csv', row.names = FALSE, quote = FALSE)
  #           
  #           # Reset playerkey
  #           pcmap <- matrix(rep(c('white','gray'), 15), nrow = 6, byrow = TRUE)
  #           write.csv(pcmap,'playerkey.csv', row.names = FALSE, quote = FALSE)
  #           
  #           # Reset random number seed
  #           id <- sample(1:99999, 1)
  #           write.csv(id,'seed.csv', row.names = FALSE, quote = FALSE)
  #           }
  #       },
  #   )
  # })
  # 
  # 
  # observeEvent(input$reveal, {
  #   # Get current game status
  #   s <- unlist(read.csv('status.csv' ,strip.white = TRUE))
  #   
  #   # If input$who is not empty, do the update
  #   if (input$who != ""){
  #     word <- toupper(input$who)
  #     
  #     # Use ALLE to reveal everything at the end of the game
  #     if (word == 'ALLE'){
  #       mastermap <- matrix(unlist(read.csv('masterkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
  #       write.csv(mastermap,'playerkey.csv', row.names = FALSE, quote = FALSE)
  #     }else{
  #       # Search the word position in the map
  #       wordpos <- which(userdata() == word, arr.ind = TRUE)
  #       
  #       # If the word was found
  #       if(!is.na(wordpos[1])){
  #         # Get the maps and do the updates
  #         mastermap <- matrix(unlist(read.csv('masterkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
  #         playermap <- matrix(unlist(read.csv('playerkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
  #         playermap[wordpos[1], wordpos[2]] <- mastermap[wordpos]
  #         write.csv(playermap,'playerkey.csv', row.names = FALSE, quote = FALSE)
  #         write.csv('update','status.csv', row.names = FALSE, quote = FALSE)
  #       }else{
  #         shinyalert("Hmm", "I can't find the word that you tried to reveal. ", type = "error")
  #       }
  #     }
  #   }else { # Do nothing 
  #   }
  # })
  # 
  # #Load data from WordMaster.csv. Reactive so that it will not be updated in one game.
  # userdatacopy <- eventReactive(input$update, {
  #   id <- unlist(read.csv('seed.csv' ,strip.white = TRUE))
  #   rawdata <- unique(unlist(read.csv('WordMaster.csv' ,strip.white = TRUE)))
  #   if (length(rawdata) < 30){
  #     shinyalert("SOS", "We need more words!", type = 'error')
  #     return(NA)
  #   }else{
  #     set.seed(id)
  #     shuffle <- sample(rawdata, 30, replace = FALSE)
  #     userdata <- matrix(shuffle, nrow = 6, byrow = TRUE)
  #     return(userdata)
  #   }
  # })
  # 
  # playerwindowtxt <- eventReactive(input$update,{
  #   return(Sys.time())
  # })
  # 
  # #Load data from WordMaster.csv. Reactive so that it will not be updated in one game.
  # userdata <- eventReactive(input$reveal, {
  #   id <- unlist(read.csv('seed.csv' ,strip.white = TRUE))
  #   rawdata <- unique(unlist(read.csv('WordMaster.csv' ,strip.white = TRUE)))
  #   if (length(rawdata) < 30){
  #     shinyalert("SOS", "We need more words!", type = 'error')
  #     return(NA)
  #   }else{
  #     set.seed(id)
  #     shuffle <- sample(rawdata, 30, replace = FALSE)
  #     userdata <- matrix(shuffle, nrow = 6, byrow = TRUE)
  #     return(userdata)
  #   }
  # })
  # 
  # 
  # output$GameTablePlayer <- DT::renderDT({
  # 
  #   playerkey <- matrix(unlist(read.csv('playerkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
  # 
  #   df <- as.data.frame(cbind(userdata(), playerkey))
  #   datatable(df,
  #             rownames = FALSE,
  #             colnames = rep("", ncol(df)),
  #             class = 'cell-border stripe',
  #             options = list(
  #               dom = "t",
  #               order = FALSE,
  #               columnDefs = list(list(className ='dt-center', targets = 0:4),
  #                                 list(visible=FALSE, targets = 5:9)
  #                                 )
  #   )) %>%
  #     formatStyle('V1', target = 'row', fontWeight = 'bold') %>%
  #     formatStyle(1:5, 6:10, backgroundColor = styleEqual(c(teamone), c(teamone))) #JS("value === '2' ? 'red' : ''")
  # })
  # 
  # output$GameTablePlayerCopy <- DT::renderDT({
  #   
  #   playerkey <- matrix(unlist(read.csv('playerkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
  #   
  #   df <- as.data.frame(cbind(userdatacopy(), playerkey))
  #   datatable(df,
  #             rownames = FALSE,
  #             colnames = rep("", ncol(df)),
  #             class = 'cell-border stripe',
  #             options = list(
  #               dom = "t",
  #               order = FALSE,
  #               columnDefs = list(list(className ='dt-center', targets = 0:4),
  #                                 list(visible=FALSE, targets = 5:9)
  #               )
  #             )) %>%
  #     formatStyle('V1', target = 'row', fontWeight = 'bold') %>%
  #     formatStyle(1:5, 6:10, backgroundColor = styleEqual(c(teamone), c(teamone))) #JS("value === '2' ? 'red' : ''")
  # })
  # 
  # output$GameTableMaster <- DT::renderDT({
  #   
  #   masterkey <- matrix(unlist(read.csv('masterkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
  #   df <- as.data.frame(cbind(userdata(), masterkey))
  #   
  #   datatable(df, rownames = FALSE, colnames = rep("", ncol(df)), 
  #             class = 'cell-border stripe',
  #             options = list(
  #               dom = "t",
  #               order = FALSE,
  #               columnDefs = list(list(className ='dt-center', targets = 0:4), 
  #                                 list(visible=FALSE, targets = 5:9) )
  #             )) %>%
  #     formatStyle('V1', target = 'row', fontWeight = 'bold') %>%
  #     formatStyle(1:5, 6:10, color = styleEqual(c('black', teamone, teamtwo, teamzero), c('white', rep('black',3)))) %>%
  #     formatStyle(1:5, 6:10, backgroundColor = styleEqual(c(teamone), c(teamone))) #JS("value === '2' ? 'red' : ''")
  # })
  # 
  # output$infoToPlayer <- renderText({
  #   out <- paste("<ul>",
  #                "<li>Game was last updated at ", playerwindowtxt(), "</li>",
  #                "</ul>")
  #   out
  # })
  # 
  # output$infoToSecurityWindow <- renderText({
  #   out <- paste("<ul>",
  #                "<li>Please click on the 'Master Window' tab.</li>",
  #                "<li>This blank page is to protect the game key.</li>",
  #                "</ul>")
  #   out
  # })
})
