library(shiny)
library(shinyWidgets)
library(dplyr)
library(ggplot2)
library(readr)
library(rworldmap)
library(plotly)
AmazonTitles <- read.csv("amazon_prime_titles.csv")
AmazonTitles <- AmazonTitles %>% select(-c(description, show_id))

Movies <- AmazonTitles %>% 
    filter(type=='Movie')

Series <- AmazonTitles %>% 
    filter(type=='TV Show')
##### -------------- Cleaning -------------------------------- #######

Movies <- Movies %>% 
    mutate(duration= gsub(pattern = " min",
                          replacement = "", 
                          x = duration))
Movies$duration <- as.numeric(Movies$duration)

Series <- Series %>% 
    mutate(Seasons= gsub(pattern = " Seasons?",
                         replacement = "", 
                         x = duration)) %>% 
    mutate(Seasons= gsub(pattern = "s",
                         replacement = "",
                         x = Seasons))
Series$Seasons <- as.numeric(Series$Seasons)

Onlist_Cat <- unlist(strsplit(AmazonTitles$listed_in, ", "))
Categories <-  unique(Onlist_Cat)
Categories <- Categories[-18]
### -------------------------------------------------- ##### 

Codes <- read_csv("countries_codes_and_coordinates.csv")
Codes <- Codes %>% select(Country, `Alpha-3 code`)

Paises <- strsplit(x = AmazonTitles$country, split = ", ")
Paises <- unlist(Paises)
Paises <- data.frame(table(Paises))
Paises <- Paises %>% rename(Country = Paises)
Paises <- left_join(x = Paises, y = Codes)
Paises <- Paises %>% rename(Code = `Alpha-3 code`)


# ----------------------------------------------------- ##

shinyServer(function(input, output, session) {
    
    output$tabla1 <- DT::renderDataTable({
        AmazonTitles %>% DT::datatable(selection = 'multiple',
                                       rownames = FALSE,
                                       filter = 'top',
                                       extensions = 'Buttons',
                                       options = list(
                                           pageLength = 10,
                                           lengthMenu = c(5,10,15),
                                           dom = 'Bfrtip',
                                           buttoms = c('csv')
                                           ))
    })
    
    output$output_tabla1 <- renderPrint({
        input$tabla1_rows_selected
    })
    
    observeEvent(input$tipo,{
        updateTabsetPanel(session,'params',selected = input$tipo)
    })
    
    
    observeEvent(input$mostrar, {     
        output$tabla2 <- DT::renderDataTable({
            if (input$tipo=='Movie'){
                Movies <- Movies %>% 
                    filter(duration <= input$dur)
                Movies <- Movies[grepl(input$genero, Movies$listed_in), ]
                Movies
            } else {
                Series <- Series %>% 
                    filter(Seasons == input$season)
                Series <- Series[grepl(input$genero, Series$listed_in), ]
                Series
            }
        })
        
    }) 
    
    
    output$grafica_mapa <- renderPlot({
        visitedMap <- joinCountryData2Map(Paises, 
                                          joinCode = "ISO3",
                                          nameJoinColumn = "Code")
        
         mapCountryData(visitedMap, 
                        nameColumnToPlot="Freq",
                        oceanCol = "azure2",
                        catMethod = "categorical",
                        missingCountryCol = gray(.8),
                        colourPalette = c("coral",
                                          "coral2",
                                          "coral3", "orangered", 
                                          "orangered3", "orangered4"),
                        addLegend = T,
                        mapTitle = "Número de titulos por país de filmacion",
                        border = NA)
    })
    
    output$grafica_rating <- renderPlotly({
        data_tabla <- AmazonTitles %>% 
            group_by(rating, year=release_year) %>% 
            summarise(Cantidad = n())
        g1 <- ggplot(data_tabla,aes(x = year,y = Cantidad, fill = rating))+
                geom_bar(stat = 'identity')
        ggplotly(g1)
    })
    
    output$grafica_tipo <- renderPlotly({
        data_tabla2 <- AmazonTitles %>% 
            group_by(type, year=release_year) %>% 
            summarise(Cantidad = n())
        g2 <- ggplot(data_tabla2, aes(x = year, y = Cantidad, colour = type))+
            geom_line(lwd=2)
        ggplotly(g2)
    })
    
    
    
})