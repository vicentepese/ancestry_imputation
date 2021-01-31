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
for (CHR in c(2)){
  data.bim_chr <- data.bim %>% filter(chr == CHR)
  gen.bim_chr <- gen.bim %>% filter(chr == CHR)
  
  # Remove duplicated position
  data.bim_chr <- data.bim_chr[!(duplicated(data.bim_chr$pos) | duplicated(data.bim_chr$pos, fromLast = TRUE)), ]
  gen.bim_chr <- gen.bim_chr[!(duplicated(gen.bim_chr$pos) | duplicated(gen.bim_chr$pos, fromLast = TRUE)), ]
  
  # Remove duplicated rsIDS
  data.bim_chr <- data.bim_chr[!(duplicated(data.bim_chr$rsid) | duplicated(data.bim_chr$rsid, fromLast = TRUE)), ]
  gen.bim_chr <- gen.bim_chr[!(duplicated(gen.bim_chr$rsid) | duplicated(gen.bim_chr$rsid, fromLast = TRUE)), ]
  
  # Parse common SNPs based on position 
  common.snps <- intersect(data.bim_chr$pos, gen.bim_chr$pos)
  
  # Get common rsIDs
  rsids.data <- data.bim_chr %>% filter(pos %in% common.snps) %>% .["rsid"]
  rsids.gen <- gen.bim_chr %>% filter(pos %in% common.snps) %>% .["rsid"]
  
  # Create dataframe 
  rsdids <- rbind(rsdids, data.frame(Data = rsids.data, Gen = rsids.gen))
}

# Write common SNPs
write.table(rsdids, file = settings$Resources$list_snps, quote = FALSE, row.names = FALSE, col.names = FALSE)
