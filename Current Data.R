library(shiny)
library(lubridate)
library(rvest)
library(stringr)
library(tibble)
library(ggplot2)
library(scales)
library(dplyr)
library(rsconnect)

LoadTodaysData <- function(month,day){

# Pull Weekends Data ------------------------------------------------------
  MovieLink <-paste0("https://www.the-numbers.com/box-office-chart/weekend/2019/",month,"/",day)
                  
  MovieLink <- read_html(MovieLink)
  
  tbls <- html_nodes(MovieLink, "table")
  
  tbls_ls <- MovieLink %>%  html_nodes("table") %>%   .[2] %>%  html_table(fill = TRUE)
  
  df <- tbls_ls[[1]]
  
  #Initialize data type
  MovieData <- as_tibble(df[, -c(1:2)])
  

# Format Data -------------------------------------------------------------

  
  MovieData$Movie <- stringr::str_sub(MovieData$Movie, 1, 20)
  MovieData$`Total Gross` <- as.numeric(gsub(",", "", str_sub( MovieData$`Total Gross`, 2, length(MovieData$`Total Gross`))))
  MovieData$Gross <-    as.numeric(gsub(",", "", str_sub( MovieData$Gross, 2, length(MovieData$Gross))))
  MovieData$`Per Thtr.` <-as.numeric(gsub(",", "", str_sub(MovieData$`Per Thtr.`, 2, length(MovieData$`Per Thtr.`)    )))
  MovieData$Change <- as.numeric(gsub(",", "", gsub("%", "", MovieData$Change))) / 100
  MovieData$`Thtrs.` <-  as.numeric(gsub(",", "", MovieData$`Thtrs.`))
  MovieData$Week <- as.numeric(MovieData$Week)

# Import Movie League Draft Data ------------------------------------------

  
  OrigMovieList <-as.data.frame(read.csv("C:/Users/JACWYD/Desktop/Rwork/MovieLeague/MovieList.csv", stringsAsFactors = FALSE))
  colnames(OrigMovieList) = c("Movie", "Owner","Bid","Factor","ReleaseDate")
  OrigMovieList <- as_tibble(OrigMovieList)
  OrigMovieList$Movie <-    stringr::str_sub(OrigMovieList$Movie, 1, 20)
 
  
 
  #OrigMovieList <- as_tibble(OrigMovieList)
# Join Current movies where movies were drafted ---------------------------


  FullData <- left_join(OrigMovieList,MovieData,by = 'Movie', keep = FALSE )
  CurrentMovies <-  distinct(as_tibble(FullData[which(!is.na(FullData$Distributor)),]))
  CurrentMovies <- add_column(CurrentMovies, day)
  return(CurrentMovies)
  
} 



HistoricalData <- LoadTodaysData(month( Sys.Date()),day( Sys.Date())-3)
Len <- length(HistoricalData$Movie)
if (Len != 0) {
  

x <- aggregate(HistoricalData$day, by = list(HistoricalData$Movie), max)

HistoricalData<- distinct(left_join(x,HistoricalData, by = c( "Group.1" = "Movie", "x" = "day"), keep = true))
HistoricalData<- HistoricalData %>% rename("Movie" = Group.1) %>% select( -x)
HistoricalData <- HistoricalData %>%  mutate(TrueGross = `Total Gross`*Factor)


WeeklyEst <- read.csv("C:/Users/JACWYD/Desktop/Rwork/MovieLeague/WeeklyEst.csv")
HistoricalData<- distinct(right_join(WeeklyEst,HistoricalData, by = "Week", keep = true))
HistoricalData <- HistoricalData %>%  mutate(EstTotal = TrueGross/Completion, Efficiency = EstTotal/Bid)

CurrentData <- read.csv("C:/Users/JACWYD/Desktop/Rwork/MovieLeague/Historical.csv")

HistoricalData <- rbind(CurrentData, HistoricalData)

write.csv(HistoricalData,"C:/Users/JACWYD/Desktop/Rwork/MovieLeague/Historical.csv")

deployApp(account = "jacobwydick")

}
