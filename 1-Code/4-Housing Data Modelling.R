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

##Making the model

m1 = readRDS(here("2-Output Datasets","master.df.clean.rds"))
set.seed(1)
m1.split = initial_split(m1, prop = 0.8)

m1.prepro = recipe(price~., data = m1) %>% 
  prep(training(m1.split))


train.df = bake(m1.prepro, training(m1.split))
test.df = bake(m1.prepro, testing(m1.split))

#Root mean squared error as loss function
RMSError = function(data, lev = NULL, model = NULL){
  
  sqerr = ((data$obs)-(data$pred))^2
  
  totalloss = sqrt((1/nrow(data))*(sum(sqerr)))
  names(totalloss) = "loss"
  totalloss
}

entrenamiento = trainControl(method = "repeatedcv", repeats = 10, number = 5, summaryFunction = RMSError)

m1.model = train(price~., data = train.df, method = "lm", trControl = entrenamiento)

##Testing the model


results = test.df %>%
  mutate(price_p = predict(m1.model, .)) %>% 
  mutate(rse = sqrt((price - price_p)^2)) 

err = sum((1/nrow(results))*results$rse )

errdistr = 100*results$rse

hist(errdistr, breaks = 10)
