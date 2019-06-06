LoadTodaysData <- function(Month, Day){
  MovieLink <-  stringr::str_interp(
      "https://www.the-numbers.com/box-office-chart/daily/2019/$[02i]{mnth}/$[02i]{day}",
      list(mnth = Month, day = Day)
    )
  MovieLink <- read_html(MovieLink)
  tbls <- html_nodes(MovieLink, "table")
  
  
  
  
  tbls_ls <- MovieLink %>%
    html_nodes("table") %>%
    .[2] %>%
    html_table(fill = TRUE)
  df <- tbls_ls[[1]]
  MovieData <- as_tibble(df[, -c(1:2)])
  
  
  MovieData$Movie <- stringr::str_sub(MovieData$Movie, 1, 20)
  MovieData$`Total Gross` <-
    as.numeric(gsub(",", "", str_sub(
      MovieData$`Total Gross`, 2, length(MovieData$`Total Gross`)
    )))
  MovieData$Gross <-
    as.numeric(gsub(",", "", str_sub(
      MovieData$Gross, 2, length(MovieData$Gross)
    )))
  MovieData$`Per Thtr.` <-
    as.numeric(gsub(",", "", str_sub(
      MovieData$`Per Thtr.`, 2, length(MovieData$`Per Thtr.`)
    )))
  MovieData$Change <-
    as.numeric(gsub(",", "", gsub("%", "", MovieData$Change))) / 100
  MovieData$`Thtrs.` <-  as.numeric(gsub(",", "", MovieData$`Thtrs.`))
  OrigMovieList <-
    as.data.frame(read.csv("MovieList.csv", stringsAsFactors = FALSE))
  colnames(OrigMovieList) = "Movie"
  OrigMovieList$Movie <-
    as.data.frame(stringr::str_sub(OrigMovieList$Movie, 1, 20),
                  stringsAsFactors = FALSE)
  names(OrigMovieList$Movie) = "Movie"

  FullData <- left_join(OrigMovieList$Movie, MovieData, by = "Movie")
  CurrentMovies <-  as_tibble(FullData[which(!is.na(FullData$Distributor)),])
   
  return(CurrentMovies)
  
} 


UpdateToITD <- function(TodaysData,dt){
  ITD <- read.csv("ITD.csv")
  
  if (max(ITD$UpdateDate) < dt) {
    TodaysData<- add_column(TodaysData,UpdateDate = dt)
    names(ITD) = names(TodaysData)
    ITDupdate <- rbind(ITD ,TodaysData )
    
    write.csv(ITDupdate,"ITD.csv", row.names = FALSE)
    return(ITDupdate)  
  }
  return(ITD)
}
