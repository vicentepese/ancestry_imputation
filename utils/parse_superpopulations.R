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
  if (subj$Population %in% c("CHB","JPT","CHS","CDX", "KHV")){
    superpop <- c(superpop, "EAS")
  } else if (subj$Population %in% c("GIH","PJL","BEB","STU","ITU")){
    superpop <- c(superpop, "SAS")
  } else if (subj$Population %in% c("YRI","LWK","GWD","MSL","ESN","ASW","ACB")){
    superpop <- c(superpop, "AFR")
  } else if (subj$Population %in% c("CEU","TSI","FIN","GBR","IBS")){
    superpop <- c(superpop, "EUR")
  } else if (subj$Population %in% c("MXL","PUR", "CLM", "PEL")){
    superpop <- c(superpop, "AMR")
    
  }
}

# Create dataframe 
sample.ethnicity <- data.frame("Sample" = sample.info$Sample, "Population" = superpop) 

# Wwrite 
write.table(sample.ethnicity, file = settings$Resources$thougen_ethnicity, quote = FALSE, sep = ',', row.names = FALSE, col.names = TRUE)
