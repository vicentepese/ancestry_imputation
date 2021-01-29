# Import libraries
library(jsonlite)
library(tidyverse)
library(readr)
library(data.table)
library(ggrepel)
library(viridis)
library(hrbrthemes)
library(HIBAG)
library(parallel)
library(ggplot2)
library(gridExtra)
library(rlist)

########### INITIALIZATION ############

# Set working directory
setwd("~/Documents/ancestry_imputation")

# Load settings
settings <- jsonlite::fromJSON('settings.json')

# Import data 
data.bim <- read.table(file = paste0("Data/", settings$Data$data_prefix, ".bim"))
gen.bim <- read.table(file= paste0(settings$Resources$CHR2_1000Genome, ".bim"))
colnames(data.bim) <- c("chr", "rsid", "len", "pos", "A1", "A2")
colnames(gen.bim) <- c("chr", "rsid", "len", "pos", "A1", "A2")

########## PARSE COMMON SNPS ###########

# Initializae Output 
rsdids <- data.frame()

# Parse CHR2
for (CHR in c(2,3)){
  data.bim <- data.bim %>% filter(chr == CHR)
  gen.bim <- gen.bim %>% filter(chr == CHR)
  
  # Remove duplicated position
  data.bim <- data.bim[!(duplicated(data.bim$pos) | duplicated(data.bim$pos, fromLast = TRUE)), ]
  gen.bim <- gen.bim[!(duplicated(gen.bim$pos) | duplicated(gen.bim$pos, fromLast = TRUE)), ]
  
  # Remove duplicated rsIDS
  data.bim <- data.bim[!(duplicated(data.bim$rsid) | duplicated(data.bim$rsid, fromLast = TRUE)), ]
  gen.bim <- gen.bim[!(duplicated(gen.bim$rsid) | duplicated(gen.bim$rsid, fromLast = TRUE)), ]
  
  # Parse common SNPs based on position 
  common.snps <- intersect(data.bim$pos, gen.bim$pos)
  
  # Get common rsIDs
  rsids.data <- data.bim %>% filter(pos %in% common.snps) %>% .["rsid"]
  rsids.gen <- gen.bim %>% filter(pos %in% common.snps) %>% .["rsid"]
  
  # Create dataframe 
  rsdids <- rbind(rsdids, data.frame(Data = rsids.data, Gen = rsids.gen))
}

# Write common SNPs
write.table(rsdids, file = settings$Resources$list_snps, quote = FALSE, row.names = FALSE, col.names = FALSE)
