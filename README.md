# Postgrad Thesis: Girona House Price Analysis
> Fotocasa Web Scrapping Project

## General info

In this project, I scrapped the data from over nine thousand houses located within the Girona province. The objective as to gather information about the current situation of Girona's real estate: you can see how different house types compare in their price ranges, or how location affects the median price of a property.

**Check the interactive data visualization [here](https://public.flourish.studio/visualisation/3139655/)
**
Also, I included a model that acts as a price appraiser. To get an appraisal, indicate:

* Square meters
* Number of rooms
* Number of bathrooms
* Location
* Type of house (flat, duplex, study, appartment...)

This price appraiser has an average error of 25%. If it predicts that a house is worth $100.000, its true value will be within $75.000-$125.000 range. 

The main limitation of the appraiser is that it doesn't have neightborhood data. The maximum granularity it has bogs down to municipality level. It is known that house prices within the same municipality wildly fluctuate based on the neightborhood.

It's not super precise, but it's good enough to get an idea of what your home might be worth.

## Setup
I used

· R (3.6.2 ver)

· RSelenium, with chromedriver ver 74.0.3729.6

It's crucial that you have chrome installed. In the line rD = rsDriver(chromever = "") you'll have to put your chromedriver version.


## Status
Finished, but unopperative. 

The project has two main limitations:

1. The scrapping process hinges on Fotocasa's HTML. A small change in their UI can invalidate whole chunks of code.
2. Fotocasa recently included protection against web crawlers. The RSelenium Server can't access the page.

## Inspiration
I had to do a project for my Postgrad thesis that could be useful to me.

By that time, my father was interested in the current situation of Girona's real estate. The problem was there was just too much information to simple "eyeball" it. So I created something that gathered and synthetized information in an effortless way.

## Contact
Created by [Daniel Beleña](https://www.linkedin.com/in/daniel-bele%C3%B1a-gonz%C3%A1lez-949917146/?locale=en_US) - feel free to contact me!
