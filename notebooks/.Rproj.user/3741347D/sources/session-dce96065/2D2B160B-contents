predictIRI_RF = function(horiz = 10, NHS = c(0,1), IH = c(0,1)){
  
  base = All_Condition_Deltas_Filtered %>%
    filter(NHS %in% NHS) %>%
    filter(F_SYSTEM %in% IH) %>%
    ungroup() %>%
    filter(YEAR_RECORD == max(YEAR_RECORD))
  
  for(i in 1:horiz-1){
    
    base_0 = base %>%
      filter(YEAR_RECORD == max(YEAR_RECORD))
    pred = predict(rf_model,base_0)
    base_0$IRI_inc = pred
    
    
    temp = base_0 %>%
      mutate(Upd_IRI = IRI + IRI_inc) %>%
      mutate(IRI = Upd_IRI) %>%
      mutate(YEAR_RECORD = YEAR_RECORD+1) %>%
      select(-Upd_IRI,-IRI_inc) %>%
      mutate(AADT_Delta = 0)
    
    base = base %>%
      rbind(temp) %>%
      arrange(ROUTE_ID, BEGIN_POINT, END_POINT, YEAR_RECORD)
  }
  base
  
}
