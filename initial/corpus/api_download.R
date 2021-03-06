library("congressbr")
library(tidyverse)
library(httr)
library(jsonlite)
library(glue)

senators <- sen_senator_list()

# loop to download 17527 individual speeches from senators that will form the larger corpus

for(i in 1:80) { try({
  endpoint <- glue(paste0("https://legis.senado.leg.br/dadosabertos/senador/",   senators$id[i], "/discursos"))
  
  raw_json <- GET(endpoint, add_headers("Accept:application/json"))
  parsed_json <- fromJSON(content(raw_json, "text"), flatten = TRUE)
  str(parsed_json)
  speeches_df <- parsed_json$DiscursosParlamentar$Parlamentar$Pronunciamentos$Pronunciamento
  
  url_list <-
    as.list(as.data.frame(t(speeches_df['UrlTextoBinario'])))
  
  names_list <- 
    as.list(as.data.frame(t(speeches_df['CodigoPronunciamento'])))  
  
  names <- 
    tidyr::expand_grid(names_list) %>%
    glue_data("{names_list}.rtf")
  
  safe_download <- safely(~ download.file(.x , .y, mode = "wb"))
  walk2(url_list, names, safe_download)}, silent=FALSE)}



