
## LOAD PACKAGES ########################
library(tidyverse)
library(caret)
library(randomForest)
library(leaflet)
library(sf)
library(reshape2)
library(xgboost)
library(shiny)
library(DT)
library(plotly)
library(shinyWidgets)
#########################################


## LOAD DATASETS AND FUNCTION ###########
# load("Analysis_Dataset.Rdata")
# load("All_Condition_Data_Deltas.Rdata")
All_Condition_Deltas_Filtered = read.csv("All_Condition_Deltas_Filtered.csv")


# source("predictIRI_RF.R")
# rf_model = readRDS("rf_model.rds")
Condition_Filepath = "../data/Condition/ModeledRegionHPMSFiles.gdb/"

Condition_2024_w_Geo = st_read(dsn = Condition_Filepath,
                               layer = "HPMS_ModReg_2024")

Geometry_2024 = Condition_2024_w_Geo %>%
  select(route_id,begin_point,end_point,county_code,Shape) %>%
  rename(ROUTE_ID = route_id,
         BEGIN_POINT = begin_point,
         END_POINT = end_point,
         geometry = Shape)
#########################################

ui = fluidPage(theme = shinythemes::shinytheme("flatly"),
               titlePanel("DDOT Pavement Condition Predictor"),
               sidebarLayout(
                 sidebarPanel(
                   fluidRow(
                     column(
                       width = 12, 
                       align = "center",
                       actionButton(
                         inputId = "Run",
                         label = "Run Model", 
                         width = "150px",                            
                         style = "height: 60px; font-size: 150%"
                       ),
                     )
                   ),
                   width = 4,
                   h3("Filters"),
                   pickerInput(
                     inputId = "NHS",
                     label = "NHS",
                     choices = c("On NHS","Off NHS"),
                     selected = c("On NHS", "Off NHS"),
                     multiple = TRUE
                     ),
                   pickerInput(
                     inputId = "IH",
                     label = "Interstate",
                     choices = c("Interstate","Non-Interstate"),
                     selected = c("Interstate","Non-Interstate"),
                     multiple = TRUE
                     ),
                   numericInput( 
                     inputId = "timespan",
                     label = "Timespan (years)",
                     value = 10,
                     min = 0,
                     max = 25,
                     step = 1
                     )),
                 
                 
                 mainPanel(width = 8,
                           tabsetPanel(
                             tabPanel("Map",
                                      h2("IRI Map"),
                                    uiOutput("year_sel_ui"),
                                    br(),
                                    leafletOutput("cond_map"),
                                    br(),
                                    h2("Route Summary"),
                                    DTOutput("cond_sum")),
                             tabPanel("Data",
                                    DTOutput("cond_tbl"))
                           
                           )
                 
               )
               )
               
               
)


server = function(input, output, session){
  
  # getVals = reactive({
  #   validate(need(input$NHS,message = ""))
  #   validate(need(input$IH,message = ""))
  #   validate(need(input$timespan,message = ""))
  #   NHS = input$NHS
  #   IH = input$IH
  #   timespan = input$timespan
  #   
  #   vals = c(NHS, IH, timespan)
  #   vals
  # })
  
  getDat = eventReactive(input$Run,{
    # validate(need(input$Run,message = "Please Press Run Button"))
    # validate(need(input$NHS,message = ""))
    # validate(need(input$IH,message = ""))
    # validate(need(input$timespan,message = ""))
    # validate(need(length(input$NHS)>0,message = "Please Select NHS Filter"))
    # validate(need(length(input$IH)>0,message = "Please Select IH Filter"))
    #vals = getVals()
    
    NHS = input$NHS#vals[1]
    IH = input$IH#vals[2]
    timespan = input$timespan#vals[3]
    
    NHS_filt = case_when(NHS == "Off NHS"~0,
                         NHS == "On NHS"~1,
                         length(NHS) == 2~c(0,1),
                         TRUE~NA)
    
    IH_filt = case_when(IH == "Non-Interstate"~0,
                        IH == "Interstate"~1,
                        length(IH) == 2~c(0,1))
    
    dat = All_Condition_Deltas_Filtered %>%
      filter(NHS %in% NHS_filt) %>%
      filter(F_SYSTEM %in% IH_filt)
    
    
    dat
    
  })
  
  runModel = eventReactive(input$Run,{
    validate(need(input$timespan, message = ""))
    
    withProgress(message = 'Generating Predictions', detail = 'Getting Data', value = 0, {
      dat = getDat()
      
      horiz = input$timespan
      
      incProgress(0.05, detail = "Splitting Data")
      
      
      train_indices_rf = createDataPartition(dat$IRI_Delta,
                                             p = 0.8,
                                             list = FALSE)
      
      train_set_rf = dat[train_indices_rf,]
      test_set_rf = dat[-train_indices_rf,] 
      
      incProgress(0.1, detail = "Creating Model")
      
      rf_model = randomForest(IRI_Delta ~ .,data = train_set_rf, ntree = 250, importance = T)
      
      incProgress(0.3, "Simulating Pavement Deterioration")
      
      base = dat %>%
        ungroup() %>%
        filter(YEAR_RECORD == max(YEAR_RECORD))
      
      for(i in 1:horiz-1){
        
        base_0 = base %>%
          filter(YEAR_RECORD == max(YEAR_RECORD))
        pred = predict(rf_model,base_0)
        base_0$IRI_inc = pred
        
        
        temp = base_0 %>%
          mutate(IRI_inc = if_else(IRI_inc < 0,0,IRI_inc)) %>%
          mutate(Upd_IRI = IRI + IRI_inc) %>%
          mutate(IRI = Upd_IRI) %>%
          mutate(YEAR_RECORD = YEAR_RECORD+1) %>%
          select(-Upd_IRI,-IRI_inc) %>%
          mutate(AADT_Delta = 0)
        
        base = base %>%
          rbind(temp) %>%
          arrange(ROUTE_ID, BEGIN_POINT, END_POINT, YEAR_RECORD)
        
      }
      
      incProgress(0.15, detail = "Finishing Up...")
      

    })
    
    base
  })
  
  output$year_sel_ui = renderUI({
    dat = runModel()
    
    yr_min = dat %>% ungroup() %>% distinct(YEAR_RECORD) %>% summarize(Min_Year = min(YEAR_RECORD,na.rm = T)) %>% pull(Min_Year)
    yr_max = dat %>% ungroup() %>% distinct(YEAR_RECORD) %>% summarize(Max_Year = max(YEAR_RECORD, na.rm = T)) %>% pull(Max_Year)
    
    pickerInput("year_sel",
                label = "Year",
                selected = yr_min,
                choices = seq(yr_min,yr_max,by=1))
    
  })
  
  output$cond_map = renderLeaflet({
    validate(need(input$Run,message = "Please Set Filters and Press Run Button"))
    dat = runModel()
    
    validate(need(input$year_sel, message = ""))
    
    yr_filt = input$year_sel
    withProgress(message = 'Creating Map', detail = '', value = 0, {
    incProgress(0.05, detail = "Processing Map Data")
    map_dat = dat %>%
      mutate(IRI = round(IRI,1)) %>%
      mutate(info = paste0("<b>Route:</b> ",ROUTE_ID, 
                           "<br/><b>Mileposts:</b> ",BEGIN_POINT,"-",END_POINT,
                           "<br/><b>IRI:</b> ",IRI)) %>%
      filter(YEAR_RECORD == yr_filt) %>%
      left_join(Geometry_2024 %>%
                  select(ROUTE_ID, BEGIN_POINT, END_POINT, geometry)) %>%
      st_as_sf() %>%
      st_zm() %>%
      mutate(IRI = if_else(IRI > 500,500,IRI))
      # mutate(IRI_Group = case_when(IRI <=90 ~ "Good",
      #                              IRI<= 170 ~ "Fair",
      #                              IRI > 170 ~ "Poor")) %>%
      # arrange(IRI_Group)
    
    pal_numeric_IRI <- colorNumeric(
      palette = c("darkgreen","green", "yellow", "red"),             
      domain = 0:500   
    )
    
    
    
    incProgress(0.15, detail = "Generating Map")
    map = map_dat %>%
      leaflet() %>%
      addPolygons(fillColor = ~pal_numeric_IRI(IRI),
                  fillOpacity = 0.7,
                  color = ~pal_numeric_IRI(IRI),    
                  weight = 2.5,
                  popup = ~info) %>%
      addProviderTiles(provider = "Esri.WorldGrayCanvas") %>%
      addLegend(
        pal = pal_numeric_IRI,
        values = 0:500,
        title = "Pavement IRI Condition",
        position = "bottomright"
      )
    
    incProgress(0.8)
  })
    
    map
    
  })
  
  output$cond_tbl = renderDT({
    
  dat = runModel()
  
  datatable(dat %>%
              select(-X),
            rownames = FALSE)
  })
  
  output$cond_sum = renderDT({
    validate(need(input$Run,message = ""))
    validate(need(input$year_sel, message = ""))
    
    dat = runModel()
    
    yr_filt = input$year_sel
    
    tab = dat %>%
      filter(YEAR_RECORD == yr_filt) %>%
      group_by(ROUTE_ID) %>%
      summarize(Min_IRI = min(IRI,na.rm = T),
                Max_IRI = max(IRI,na.rm = T),
                Mean_IRI = round(mean(IRI,na.rm = T),2),
                Median_IRI = median(IRI,na.rm = T),
                SD_IRI = round(sd(IRI,na.rm = T),2)) %>%
      arrange(ROUTE_ID)
    
    datatable(tab)
  })
  
 
  
}

shinyApp(ui, server)