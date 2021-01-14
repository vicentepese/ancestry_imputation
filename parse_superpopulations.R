# Library
library(xlsx)
library(jsonlite)
library(readxl)

# Set working directory 
setwd("~/Documents/ancestry_imputation")

# Read settings 
settings <- jsonlite::read_json("settings.json")

# Load 1000 genome sample
sample.info <- read_excel(settings$Resources$thougen_sample)

# Get superpulation 
superpop <- c()
for (i in 1:nrow(sample.info)){
  
  # Get ID
  subj <- sample.info[i,]
  
  # Get superpopulation 
  if (subj$Population %in% c("CDX","CHB","JPT","KHV")){
    superpop <- c(superpop, "EAS")
  } else if (subj$Population %in% c("CHS","BEB","GIH","ITU","PJL","STU")){
    superpop <- c(superpop, "SAS")
  } else if (subj$Population %in% c("ASW","ACB","ESN","GWD","LWK","MSL","YRI")){
    superpop <- c(superpop, "AFR")
  } else if (subj$Population %in% c("GBR","FIN","IBS","TSI","CEU")){
    superpop <- c(superpop, "EUR")
  } else if (subj$Population %in% c("CLM","MXL", "PEL", "PUR")){
    superpop <- c(superpop, "AMR")
    
  }
}