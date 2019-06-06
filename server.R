#
# Movie League Shiny App Server
# Assumptions: Data is update.
# Updated every Monday
#
rm(list = ls())
library(shiny)
#library(lubridate)
#library(rvest)
#library(stringr)
#library(tibble)
library(ggplot2)
library(scales)
library(dplyr) 
library(DT)
# Define server logic required to draw a histogram


shinyServer(function(input, output) {
  Data <- read.csv("Historical.csv",stringsAsFactors = FALSE)
  Data$Movie <- gsub("'", "", Data$Movie)
  MovieData <- read.csv("MovieList.csv",stringsAsFactors = FALSE)
  names(MovieData) <- c("Movie","Owner", "Bid", "Factor", "ReleaseDate")
  MovieData$Movie <- gsub("'", "", MovieData$Movie)
  
  Table <- Data[ , c("Movie","Owner", "TrueGross","EstTotal","Efficiency") ]  
  Table <- datatable(Table, options = list(  pageLength = 100, order = list(3,"desc"),dom = 't')) %>% formatCurrency(c("TrueGross","EstTotal","Efficiency"))
            
  output$CurrentMovieTable <- renderDT( Table )
   
  
  
  output$UserList <- renderDT(  if(input$Competitor != "Pick A Competitor"){
      datatable(MovieData[which(MovieData$Owner == tolower(input$Competitor)),c("Movie","Bid","ReleaseDate")], options = list(dom = 't')) %>% formatDate("ReleaseDate",'toLocaleDateString')
    
   })
  RankingTable <- tibble::as_tibble(Data) %>% group_by(Owner) %>% dplyr::summarise(Total = sum(TrueGross))
  RankingTable <- datatable(RankingTable, options = list(pageLength = 10, order = list(2,"desc"), dom = 't',columnDefs = list(list(className = 'dt-center', targets = 2)))) %>% formatCurrency("Total") 
  
  output$Ranking <- renderDT(RankingTable)
    
})



