#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyalert)
library(DT)

Sys.setenv(TZ = 'US/Eastern')

shinyServer(function(input, output, session) {
  teamzero <- '#FBDE445F' #Yellow
  teamone <- '#F650585F'  #Red
  teamtwo <- '#6495EDFF'   #Blue
  #teamzero <- '#28334A5F'

  receipt <- c(' a beautiful', ' a tricky',' a brutal', ' a fabulous', ' a fantastic', ' an interesting', ' a long')

  # Collect words for the game
  observeEvent(input$submit, {
    # Get current game status
    s <- unlist(read.csv('status.csv' ,strip.white = TRUE))
    if (s == 'lock'){
      msg_full <- HTML("<b><em>We have enough words for now. <br>Please resubmit at a later time.</em></b>")
      shinyalert("Thank you!", msg_full, type = "info", html = TRUE)
    }else if(s == 'open' & input$word == '#test#'){
      # Pre-populate the list for testing
      close( file( 'WordMaster.csv', open="w" ) )
      write.table(1:28, 'WordMaster.csv', row.names = FALSE, col.names = 'Words', quote = FALSE, sep = ",")
    }else {
      rmhyphen <- gsub('-', '', input$word)
      if (input$word != "" & grepl('[[:punct:]]|[[:space:]]', rmhyphen)){
        msg_sorry <- HTML("<b><em>No special characters or spaces please :)</em></b>")
        shinyalert("Sorry!", msg_sorry, type = "error", html = TRUE)
      }else if (input$word != "" & !grepl('[[:punct:]]', rmhyphen)){
        if (toupper(input$word) == "ALLE"){
          msg_protect <- HTML("<b><em>ALLE is a protected word :)</em></b>")
          shinyalert("Oops", msg_protect, type = "error", html = TRUE)
        }else{
          write.table(toupper(input$word), 'WordMaster.csv', append = TRUE,
                      col.names = FALSE, row.names = FALSE,
                      quote = FALSE, sep = "")
          shinyalert(title = paste('Awesome, ', toupper(input$word), ' is', sample(receipt, 1),' word.'), type = "success")
          updateTextInput(session,"word", "Words Submission Box", "")
        }
      }else{
        msg_blank <- HTML("<b><em>Looks like you forgot to type in a word. :)</em></b>")
        shinyalert("Hmm", msg_blank, type = "error", html = TRUE)
      }
    }
    
  })

  observeEvent(input$role, {
    if (input$role == 'master'){
      updateTabsetPanel(session, "Home", "Security Window")
      msg_enter_master <- HTML("<em>Are you sure you want to control the game as a master? <br>Type 'Master' to proceed.</em>")
      shinyalert(msg_enter_master, type = 'input', html = TRUE,
                 callbackR = function(x) { if(x != 'Master'){
                    updateRadioButtons(session, 'role',selected = 'player')
                  }
      })
    }
  })



  # Erase all existing words
  observeEvent(input$erase, {
    msg_new_game <- HTML("<em>This will erase everything and start a completely new game. <br>Type 'Erase' to proceed.</em>")
    shinyalert(
      msg_new_game, type = "input", html = TRUE,
      callbackR = function(x) { if(x == 'Erase') {
            close( file( 'WordMaster.csv', open="w" ) )

            # Reset words
            write.table("", 'WordMaster.csv', row.names = FALSE, col.names = 'Words', quote = FALSE, sep = ",")

            # Reset status
            close( file( 'status.csv', open="w" ) )
            write.table("open", 'status.csv', row.names = FALSE, col.names = 'Status', quote = FALSE)

            # Reset masterkey
            mcpool <- sample(c(rep(teamone, 9), rep(teamtwo, 9), rep(teamzero,11), 'black'))
            mcmap <- matrix(mcpool, nrow = 6, byrow = TRUE)
            write.csv(mcmap,'masterkey.csv', row.names = FALSE, quote = FALSE)

            # Reset playerkey
            pcmap <- matrix(rep(c('#F0F0F0'), 30), nrow = 6, byrow = TRUE)
            write.csv(pcmap,'playerkey.csv', row.names = FALSE, quote = FALSE)

            # Reset random number seed
            set.seed(Sys.time())
            id <- sample(1:99999, 1)
            write.csv(id,'seed.csv', row.names = FALSE, quote = FALSE)
            
            # Clear textbox
            updateTextInput(session,"who", "Reveal the identity of the word:", "")
            }
        },
    )
  })


  observeEvent(input$reveal, {
    
    s <- unlist(read.csv('status.csv' ,strip.white = TRUE))
    
    # If input$who is not empty, do the update
    if (input$who != "" & s == 'lock'){
      word <- toupper(input$who)

      # Use ALLE to reveal everything at the end of the game
      if (word == 'ALLE'){
        mastermap <- matrix(unlist(read.csv('masterkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
        write.csv(mastermap,'playerkey.csv', row.names = FALSE, quote = FALSE)
      }else{
        # Search the word position in the map
        wordpos <- which(userdata() == word, arr.ind = TRUE)

        # If the word was found
        if(!is.na(wordpos[1])){
          # Get the maps and do the updates
          mastermap <- matrix(unlist(read.csv('masterkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
          playermap <- matrix(unlist(read.csv('playerkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
          playermap[wordpos[1], wordpos[2]] <- mastermap[wordpos]
          write.csv(playermap,'playerkey.csv', row.names = FALSE, quote = FALSE)
        }else{
          shinyalert("Hmm", "I can't find the word that you tried to reveal. ", type = "error")
        }
      }
    }else{ 
      # The following cases directly go to userdata()
      # (1)status = lock, text = empty. 
      # (2)status = open.
    }
  })

  
  #Load data from WordMaster.csv. Reactive so that it will not be updated in one game.
  userdata <- eventReactive(input$reveal, {
    rawdata <- toupper(unique(unlist(read.csv('WordMaster.csv' ,strip.white = TRUE))))
    if (length(rawdata) < 30){
      # With less than 30 words
      msg_more <- HTML("<b><em>We need more words! :)</em></b>")
      shinyalert("SOS", msg_more, type = 'info', html = TRUE)
      return(NA)
    }else{ 
      # with 30 or more words
      # Lock the WordMaster.csv if it is open 
      s <- unlist(read.csv('status.csv' ,strip.white = TRUE))
      if (s == 'open'){
        write.csv('lock','status.csv', row.names = FALSE, quote = FALSE)
      }
      id <- unlist(read.csv('seed.csv' ,strip.white = TRUE))
      set.seed(id)
      shuffle <- sample(rawdata, 30, replace = FALSE)
      userdata <- matrix(shuffle, nrow = 6, byrow = TRUE)
      return(userdata)
    }
  })
  
  
  #Load data from WordMaster.csv. Reactive so that it will not be updated in one game.
  userdatacopy <- eventReactive(input$refresh, {
    
    rawdata <- toupper(unique(unlist(read.csv('WordMaster.csv' ,strip.white = TRUE))))
    if (length(rawdata) < 30){
      msg_more <- HTML("<b><em>We need more words! :)</em></b>")
      shinyalert("SOS", msg_more, type = 'info', html = TRUE)
      return(NA)
    }else{
      s <- unlist(read.csv('status.csv' ,strip.white = TRUE))
      if (s == 'open'){
        msg_wait <- HTML("<b><em>Ask your word masters to start the game! :)</em></b>")
        shinyalert("Wait", msg_wait, type = 'info', html = TRUE)
        return(NA)
      }else{
        id <- unlist(read.csv('seed.csv' ,strip.white = TRUE))
        set.seed(id)
        shuffle <- sample(rawdata, 30, replace = FALSE)
        userdata <- matrix(shuffle, nrow = 6, byrow = TRUE)
        return(userdata)
        #return(userdata())
      }
    }
  })

  playerwindowtxt <- eventReactive(input$refresh,{
    return(Sys.time())
  })


  output$GameTablePlayer <- DT::renderDT({

    playerkey <- matrix(unlist(read.csv('playerkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)

    df <- as.data.frame(cbind(userdata(), playerkey))
    datatable(df,
              rownames = FALSE,
              colnames = rep("", ncol(df)),
              class = 'cell-border stripe',
              options = list(
                dom = "t",
                order = FALSE,
                columnDefs = list(list(className ='dt-center', targets = 0:4),
                                  list(visible=FALSE, targets = 5:9)
                                  )
    )) %>%
      formatStyle('V1', target = 'row', fontWeight = 'bold') %>%
      formatStyle(1:5, 6:10, backgroundColor = styleEqual(c(teamone), c(teamone))) #JS("value === '2' ? 'red' : ''")
  })

  output$GameTablePlayerCopy <- DT::renderDT({

    playerkey <- matrix(unlist(read.csv('playerkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)

    df <- as.data.frame(cbind(userdatacopy(), playerkey))
    datatable(df,
              rownames = FALSE,
              colnames = rep("", ncol(df)),
              class = 'cell-border stripe',
              options = list(
                dom = "t",
                order = FALSE,
                columnDefs = list(list(className ='dt-center', targets = 0:4),
                                  list(visible=FALSE, targets = 5:9)
                )
              )) %>%
      formatStyle('V1', target = 'row', fontWeight = 'bold') %>%
      formatStyle(1:5, 6:10, backgroundColor = styleEqual(c(teamone), c(teamone))) #JS("value === '2' ? 'red' : ''")
  })

  output$GameTableMaster <- DT::renderDT({

    masterkey <- matrix(unlist(read.csv('masterkey.csv' ,strip.white = TRUE)), nrow = 6, byrow = FALSE)
    df <- as.data.frame(cbind(userdata(), masterkey))

    datatable(df, rownames = FALSE, colnames = rep("", ncol(df)),
              class = 'cell-border stripe',
              options = list(
                dom = "t",
                order = FALSE,
                columnDefs = list(list(className ='dt-center', targets = 0:4),
                                  list(visible=FALSE, targets = 5:9) )
              )) %>%
      formatStyle('V1', target = 'row', fontWeight = 'bold') %>%
      formatStyle(1:5, 6:10, color = styleEqual(c('black', teamone, teamtwo, teamzero), c('white', rep('black',3)))) %>%
      formatStyle(1:5, 6:10, backgroundColor = styleEqual(c(teamone), c(teamone))) #JS("value === '2' ? 'red' : ''")
  })

  output$infoToPlayer <- renderText({
    out <- paste("<ul>",
                 "<li><em>Use the</em> <b>Refresh the Game</b> <em>button to update the game</em>.</li>",
                 "<li><em>Game was last updated at ", playerwindowtxt(), " EST</em></li>",
                 "</ul>")
    out
  })

  output$infoToSecurityWindow <- renderText({
    out <- paste("<ul>",
                 "<li><em>Please click on the 'Master Window' tab.</em></li>",
                 "<li><em>This blank page is to protect the game key.</em></li>",
                 "</ul>")
    out
  })
  
  output$infoToMaster1 <- renderText({
    out <- paste("<ul>",
                 "<li><em>Use the</em> <b>Go/Reveal</b> <em>button to start the game.</em></li>",
                 "<li><em>Use the</em> <b>Go/Reveal</b> <em>button to reveal the status of the word in the textbox to players.</em></li>",
                 "<li><em>Use the master word</em> <b>ALLE</b> <em>to reveal the status of all words.</em></li>",
                 "<li><em>Use the</em> <b>Erase Game</b> <em>button to erase all the words before a new game.</em></li>",
                 "<li><font style='background-color:#F650585F;'><em><b>Team Red</b></em></font> ",
                 "<font style='background-color:#6495EDFF;'><em><b>Team blue</b></em></font> ",
                 "<font style='background-color:#FBDE445F;'><em><b>Civilians</b></em></font> ",
                 "<font style='background-color:black; color:white'><em><b>Assassin</b></em></font> </li>",
                 "</ul>")
    out
  })
  
  output$infoToMaster2 <- renderText({
    out <- paste("<ul>",
                 "<li><em>The table below is what the players can see so far.</em></li>",
                 "</ul>")
    out
  })
})
