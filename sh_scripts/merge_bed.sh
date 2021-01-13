# Read settings
DATA=$(jq -r '.Data.data_prefix' settings.json)
THOU_DATA=$(jq -r '.Resources.CHR2_1000Genome' settings.json)
OUTPUT=$(jq -r '.Data.merged_data' settings.json)
SNPS_FILE=$(jq -r '.Resources.list_snps' settings.json)
REMSNPS_FILE=$(jq -r '.Resources.remove_snps' settings.json)

# Parse CHR2
module load plink2
plink2 --bfile $THOU_DATA --chr 2 --make-bed --rm-dup exclude-all --out temp_1000gen
plink2 --bfile $DATA --chr 2 --make-bed --rm-dup exclude-all --out temp_data

# Run Rscript 
module load r/4.0.3
Rscript filter_snps.R

# Get common SNPs and exclude duplicates/multi-allelic
SNPS=$(awk '{{ORS=", "} {print $0}}' $SNPS_FILE)
EXCLUDE=$(awk '{{ORS=", "} {print $0}}' $REMSNPS_FILE)

# Filter files individually
plink2 --bfile temp_1000gen --make-bed --snps $SNPS --exclude-snps $EXCLUDE --out filt_1000gen 
plink2 --bfile temp_data --make-bed --snps $SNPS --exclude-snps $EXCLUDE--out filt_tempdata

# Merge attempt
module load plink
plink --bfile filt_tempdata --bmerge filt_1000gen --out tst

# Flip and merge
plink --bfile filt_1000gen --flip tst.missnp --make-bed --out filt_1000gen_flip_temp
plink --bfile filt_tempdata --bmerge filt_1000gen_flip_temp --out $OUTPUT

# Remove 
rm -r *temp*
rm -r *filt*