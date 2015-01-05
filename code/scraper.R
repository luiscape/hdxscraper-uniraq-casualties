# Script to download and clean
# OCHA Syria's topline figures.
# Directly from their website.

onSw <- function(d = T) {
  if (d == T) return('tool/')
  else return('')
}

# dependencies
library(RCurl)
library(XML)
library(reshape2)

# helper functions
source(paste0(onSw(), 'code/write_tables.R'))
source(paste0(onSw(), 'code/sw_status.R'))

# configuration
uniraq_url = 'http://www.uniraq.org/index.php?option=com_k2&view=itemlist&layout=category&task=category&id=159&Itemid=633&lang=en'

# Function to scraper casualty data from 
# the UN Iraq website.
scrapeData <- function(url) {
    
  cat('----------------------------------------\n')
  cat('Scraping data from the UN-Iraw website.\n')
  cat('----------------------------------------\n')
  
  # getting the html
  doc <- readHTMLTable(url)
  
  # transforming the data.frame and adding names
  data <- as.data.frame(doc)
  data = data[-1, ]
  names(data) <- c('Month', 'Killed', 'Injured')
  
  # cleaning
  data$Killed <- as.numeric(data$Killed)
  data$Injured <- as.numeric(data$Injured)
  
  # Melting to a long format
  data <- melt(data, id.vars = 'Month')
  
  # results
  cat('-------------------------------\n')
  cat('Done!\n')
  cat('-------------------------------\n')
  return(data)
  
}



# Scraper wrapper
runScraper <- function() {
  data <- scrapeData(uniraq_url)
  writeTable(data, 'uniraq_casualty_data', 'scraperwiki')
}

# Changing the status of SW.
tryCatch(runScraper(),
         error = function(e) {
           cat('Error detected ... sending notification.')
           system('mail -s "UN Iraq Casualty Figures failed." luiscape@gmail.com')
           changeSwStatus(type = "error", message = "Scraper failed.")
           { stop("!!") }
         }
)

# If success:
changeSwStatus(type = 'ok')
