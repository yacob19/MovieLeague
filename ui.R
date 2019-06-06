#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(datasets)
library(DT)
# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("2019 Symetra Movie Leauge: I Updated Automatically on Monday morning at 8am"),

    # Sidebar with a selector for person name
    sidebarLayout(
        sidebarPanel(  
          
            DTOutput("Ranking")
          
            ,selectInput("Competitor", "Competitor:",
                        choices = c("Pick A Competitor","Michael","Jake", "Curtis", "John", "Nathan", "Sam", "Brian", "Trevor", "Jacob", "Alex"))
        
            ,DTOutput("UserList")   
            
    ),
    
    
    
        # Show a plot of the generated distribution
        mainPanel(
            DTOutput("CurrentMovieTable"  )
        )
    )
))


