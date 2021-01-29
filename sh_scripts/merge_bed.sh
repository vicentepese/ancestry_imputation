# Read settings
PREFIX=$(jq -r '.Data.data_prefix' settings.json)
THOU_DATA=$(jq -r '.Resources.CHR2_1000Genome' settings.json)
OUTPUT=$(jq -r '.Data.merged_data' settings.json)
SNPS_FILE=$(jq -r '.Resources.list_snps' settings.json)
REMSNPS_FILE=$(jq -r '.Resources.remove_snps' settings.json)

# Parse SNPS
Rscript parse_SNPS.R

# Get common SNPs for each file 
awk '{print $1}' $SNPS_FILE > snps_data
awk '{print $2}' $SNPS_FILE > snps_gen

# Filter files individually
plink --bfile Data/$PREFIX --make-bed --chr 2,3 --extract snps_data --allow-no-sex --out filt_1000gen 
plink --bfile $THOU_DATA --make-bed --chr 2,3  --extract snps_gen --allow-no-sex --out filt_tempdata

# Merge attempt
plink --bfile filt_tempdata --bmerge filt_1000gen --out Data/$OUTPUT

# Remove 
rm -r *temp*
rm -r *filt*
rm -r *snps*
