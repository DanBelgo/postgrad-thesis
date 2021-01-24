####Loading Packages

library(tidyverse)
library(stringr)
library(magrittr)
library(tidymodels)
library(caret)
library(psycho)
library(rsample)
library(MLmetrics)
library(yardstick)
library(VIM)

####Loading and precleaning the dataset

t = readRDS(here("2-Output Datasets","master.df.rds")) 

#Transforms all NAs into 0s. There's a lot of unreported data. 

t[is.na(t)] = "0"
t[t == "character(0)"] = 0
t[t == "NULL"] = 0


df = data.frame(lapply(t, unlist), stringsAsFactors = T)


# We clean the variables first, as they're in string form
df$price = str_remove(df$price, "\\.")
df$price = str_remove(df$price, "\\.")
df$price = str_replace(df$price, "€", "")
df$habs =  str_replace(df$habs, "habs.", "")  
df$habs = str_replace(df$habs, "hab." , "")
df$bath =  str_replace(df$bath, "baño", "") 
df$bath =  str_replace(df$bath, " s", "") 
df$m2 =  str_replace(df$m2, "m²", "") 
df$price.m2 = str_replace(df$price.m2, "€/m²", "") 
df$price.m2 = str_remove(df$price.m2, "\\.")
df$price.m2 = str_remove(df$price.m2, "\\.")
df$terreno = str_remove(df$terreno, "m² terreno")

# We assign each variable its correct type (numerical or categorical)
df$price = as.double(df$price)
df$habs = as.numeric(df$habs)
df$bath = as.numeric(df$bath)
df$m2 = as.numeric(df$m2)
df$terreno = as.numeric(df$terreno)
df$price.m2 = as.numeric(df$price.m2)
df$comarca = as.factor(df$comarca)
df$provincia = as.factor(df$provincia)
df$municip = as.character(df$municip)
df$municip = as.factor(df$municip)
df$price.m2 = as.numeric(df$price.m2)

#All set to do a major cleaning!

####Cleaning and Wrangling: prepping the variables for analysis


# Some houses have 0 rooms. They're studies. It's a bit problematic, so we'll split them apart to fix it.

estud = df %>% select(price, habs, bath, m2, Tipo.de.inmueble, municip) %>% 
  as.tibble() %>% 
  na.omit %>% 
  filter(Tipo.de.inmueble == "Estudio") %>% 
  filter(m2 > 0) %>% 
  mutate(habs = 1)

#Outlier removal + log transform price and square meters

m1 = df %>% 
  select(price, habs, bath, m2, Tipo.de.inmueble, municip) %>% 
  as.tibble() %>% 
  na.omit %>% 
  filter(price<1000001) %>% 
  filter(m2<2500) %>% 
  filter(m2>0) %>% 
  filter(Tipo.de.inmueble != "Loft") %>% 
  filter(Tipo.de.inmueble != "Estudio") %>% 
  bind_rows(estud) %>% 
  mutate(price = log(price), m2 = log(m2)) %>% 
  filter(habs<11) %>% 
  filter(bath<7) %>% 
  mutate(habs = round(habs+0.1))

m1$habs = as.integer(m1$habs)
m1$bath = as.integer(m1$bath)

# 70 houses report to have 0 rooms and baths. We transform them into NAs to input values by K-nearest-neightborss via kNN
m1[m1 == 0] = NA
m1 = kNN(m1, variable = c("habs","bath"), k = 6, imp_var = F)

# Data exploration
boxplot((m1$price))
hist((m1$price), breaks = 7)

ggplot(data = m1, mapping = aes(x = m2, y = price))+
  geom_point()

ggplot(data = m1, mapping = aes(x = habs, y = price))+
  geom_col()

ggplot(data = m1, mapping = aes(x = bath, y = price))+
  geom_col()

##Saving the clean dataframe

saveRDS(m1, here("2-Output Datasets","master.df.clean.rds"))
