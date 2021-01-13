# Library
library(dplyr)
library(jsonlite)

# Read settigns
settings <- jsonlite::fromJSON('settings.json')

# Read files
thougen.df <- read.table(paste0(settings$Resources$CHR2_1000Genome, ".bim"))
data.df <- read.table(paste0(settings$Data$data_prefix, ".bim"))

# Get common snps
`%notin%` <- Negate(`%in%`)
snps <- which(data.df$V2 %in% thougen.df$V2)
snps <- data.df$V2[snps]

# Get multialleic/duplicates/different locations
remove <- c()
for (snp in snps){
  # Get snps in each dataset
  data.snp <- data.df %>% filter(V2 == snp); gen.snp <- thougen.df %>% filter(V2 == snp)
  
  if (data.snp$V4 != gen.snp$V4){
    remove <- c(remove, snp)
  } else if(grepl(data.snp$V5, pattern = "I") | grepl(data.snp$V6, pattern = "D") |
            grepl(gen.snp$V5, pattern = "I") | grepl(gen.snp$V6, pattern = "D" ) | 
            nchar(data.snp$V5) != nchar(gen.snp$V5) | nchar(data.snp$V6) != nchar(gen.snp$V6)){
    remove <- c(remove, snp)
  }
}
remove <- unique(remove)

# Write 
write.table(snps, file=settings$Resources$list_snps, sep="\t", col.names=F, row.names=F, quote=F )
write.table(remove, file = settings$Resources$remove_snps, sep ="\t", col.names = F, row.names = F, quote=F)
