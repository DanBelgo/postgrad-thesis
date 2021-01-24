####Loading Packages
library(tidyverse)
library(rvest)
library(stringr)
library(rebus)
library(lubridate)
library(magrittr)
library(RSelenium)
library(xml2)
library(beepr)
library(here)

####We're going to create a bunch of functions to extract the data from each house

get_headers = function(x){x$getElementText()} #this function is the lynchpin for the next function


#This function extracts: price, number of rooms, number of baths, how many square meters it has, and other listed attributes such as heating, if it has a pool, etc

get_details = function(html){
  
  remDr$navigate(html)
  
  elements = remDr$findElements("tag name", "span")
  
  # This extracts the first listed elements: how many rooms, baths...
  x = remDr$findElements("class", "re-DetailHeader-featuresItem") %>% 
    sapply(get_headers) %>% 
    unlist()
  
  L2 = list(habs = str_subset(x,"hab"),
            bath = str_subset(x,"baño"),
            m2 = str_subset(x," m")[1],
            terreno = str_subset(x,"terreno"),
            price.m2 = str_subset(x,"/m"))
  
  headers = as.data.frame(matrix(L2,1, dimnames = list(NULL,names(L2))))
  
  # This extracts the price data
  price = remDr$findElements("class", "re-DetailHeader-price") %>% 
    sapply(get_headers) %>% 
    unlist %>% 
    data.frame(price = .)
  
  # This extracts the location data
  
  loc = remDr$findElements("class", "re-Breadcrumb-item") %>% 
    sapply(get_headers) %>% 
    unlist
  
  L3 = list(provincia = loc[1],
            comarca = loc[2],
            municip = loc[3]
  )
  
  location = as.data.frame(matrix(L3,1, dimnames= list(NULL,names(L3))))
  
  
  # This extracts tags: if the house has furniture, air conditioning, etc.
  
  xtr = tryCatch(
    {
      remDr$findElements("class","re-DetailExtras") %>% 
        sapply(get_headers) %>% 
        str_split("\n", n= 100) %>% 
        unlist() %>%
        str_sort() %>% 
        unique() %>% 
        data.frame(., call = 1) %>%
        t() %>% 
        `colnames<-`(.[1,]) %>% 
        as_tibble() %>% 
        slice(-1)
    },
    error = function(cond){
      message("This house doesn't have extras")
      message(cond)
      return(xtr = data.frame(NA))
    }
  )
  
  ##This extracts the house type (flat, attic, house, etc), and a small list of features
  details = remDr$findElements("class","re-DetailFeaturesList-feature") %>% 
    sapply(., get_headers) %>% 
    str_split("\n", n = 2)   %>% 
    unlist()
  
  det = as.data.frame(matrix(details, 2 ), stringsAsFactors = FALSE) %>% 
    `colnames<-`(.[1,]) %>% 
    slice(-1)
  
  ##We merge all the extracted data into one dataset
  
  df = data.frame(price, headers, det, location) %>% 
    bind_cols(xtr)
  
  df
}

# This loop enters each page listed in master_urls. TryCatch acts as insurance against errors: if the function fails to get the data, it skips to the next iteration

master.df = data.frame()
master_urls = readRDS(here("2-Output Datasets","master_urls.rds"))

for (i in master_urls){
  error = tryCatch(
    get_details(i),
    error = function(e){e}
  )
  
  if(!inherits(error, "error")){
    det = get_details(i)
    master.df = bind_rows(master.df, det)
  }
}

# We save the df with the raw housing data as an RDS object
saveRDS(master.df, here("2-Output Datasets","master.df.rds"))