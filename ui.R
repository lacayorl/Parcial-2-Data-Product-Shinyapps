library(shiny)
library(dplyr)
library(shinyWidgets)
library(plotly)
shinyUI(fluidPage(
    
    setBackgroundColor(
        color = c("#F7FBFF", "#2171B5"),
        gradient = "linear",
        direction = "bottom"
    ),
    
    titlePanel("Amazon Prime Video Web App"),
    tabsetPanel(
        tabPanel('Buscador',
                 h1('¿No sabes que ver?'),
                 selectInput('genero','Genero',
                             choices = Categories
                             ),
                 selectInput('tipo', 'Tipo',
                             choices = AmazonTitles$type
                             ),
                 tabsetPanel(
                     id='params',
                     type='hidden',
                     tabPanel('Movie',
                              sliderInput('dur', 'Duración en minutos',
                                          value = mean(Movies$duration), 
                                          min = min(Movies$duration),
                                          max = max(Movies$duration)
                                          )
                              ),
                     tabPanel('TV Show',
                              selectInput('season', 'Season',
                                          choices = sort(Series$Seasons)
                                          ))
                              ),
                 
                 actionButton(inputId = 'mostrar', label = "Ver Resultados", 
                              icon = icon("refresh"), 
                              style="color: #fff; background-color: #e95420; border-color: #c34113;
                                 border-radius: 10px; 
                                 border-width: 2px"),
                 hr(),
                 DT::dataTableOutput('tabla2'),
                 verbatimTextOutput('output_tabla2')
                 
                 ),
        tabPanel('Info del contenido en Prime Video',
                 h1('Geo informacion'),
                 plotOutput('grafica_mapa'),
                 h1('Cantidad de titulos por año de filmación y rating'),
                 plotlyOutput('grafica_rating'),
                 h1('Cantidad de títulos por año de filmación y tipo'),
                 plotlyOutput('grafica_tipo')
                
                ),
        tabPanel('Descargar dataset',
                 h1('Títulos en Amazon'),
                 fluidRow(column(12,
                                 DT::dataTableOutput('tabla1'),
                                 verbatimTextOutput('output_tabla1')
                                )
                         )
                )
        
    )
    
))
