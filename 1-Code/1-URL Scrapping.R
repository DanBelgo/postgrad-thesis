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
#
####Setting up the Scrapper####

# We define the first index page 

url = ("https://www.fotocasa.es/es/comprar/viviendas/girona-provincia/todas-las-zonas/l?latitude=41.9829&longitude=2.8245&combinedLocationIds=724,9,17,0,0,0,0,0,0")

# Function to get the last page from Fotocasa Index
get_last_page = function(html){
  pages_data = html %>% 
    html_nodes(".sui-PaginationBasic-item") %>% 
    html_text()
  
  pages_data[(length(pages_data)-1)] %>% 
    unname() %>% 
    as.numeric()
}

first_page = read_html(url)
(latest_page_number = get_last_page(first_page))

# We create the list of URLs, so the scrapper can crawl through them

list_of_pages = str_c("https://www.fotocasa.es/es/comprar/viviendas/girona-provincia/todas-las-zonas/l/", 1:latest_page_number, "?latitude=41.9829&longitude=2.8245&combinedLocationIds=724,9,17,0,0,0,0,0,0")

# We create the RSelenium server (Chrome)

rD = rsDriver(chromever = "[your chromedriver version]")
remDr = rD$client
remDr$navigate(url)


# This function gets the links from all listed houses within a page

get_links = function(x){x$getElementAttribute("href")}


master_urls = list()


#This loop enters each page from list_of_pages, scrolls down in order to load the HTML, extracts the links from all listed houses, and stores them in a list
#The TryCatch is used to fix any errors that pop during the scrapping process.
#WARNING: The loop is slow. It'll take from hours to days to end. I recommend you to run the script in Google Cloud or AWS.

for (i in list_of_pages){
  err = tryCatch(
    remDr$navigate(i),
    newurl = unlist(sapply(remDr$findElements("class","re-Card-link"), get_links)),
    err = function(e){e}
  )
  
  if(!inherits(err, "error")){
    remDr$navigate(i)
    for(i in 1:13){      
      remDr$executeScript(paste('scroll(0,',i*750,');'))
      Sys.sleep(1)
    }
    # It gets the links from all listed houses, and adds them to a list
    item_element = remDr$findElements("class","re-Card-link")
    
    newurl = unlist(sapply(item_element, get_links))
    master_urls = append(master_urls,newurl) 
  }    
}
?here
####We save the URLs as a RDS file####
saveRDS(master_urls, here("2-Output Datasets","master_urls.rds")