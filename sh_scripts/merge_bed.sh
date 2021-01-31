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
plink --bfile Data/$PREFIX --make-bed --chr 2 --extract snps_data --allow-no-sex --out filt_tempdata 
plink --bfile $THOU_DATA --make-bed --chr 2  --extract snps_gen --allow-no-sex --out filt_1000gen

# Modify .fam file to match RSids from 1000 Genome
awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' filt_1000gen.bim filt_tempdata.bim > tst && mv tst filt_tempdata.bim

# Merge attempt
plink --bfile filt_tempdata --bmerge filt_1000gen --out Data/$OUTPUT

# If issue with alleles, filter independently and merge 
if test -f "Data/$OUTPUT.missnp"; then 
    # Remove multiallelic
    plink --bfile filt_tempdata --exclude  Data/$OUTPUT.missnp --make-bed --out tst
    for i in tst.*; do mv "$i" "filt_tempdata.${i##*.}"; done

    plink --bfile filt_1000gen --exclude Data/$OUTPUT.missnp --make-bed --out tst
    for i in tst.*; do mv "$i" "filt_1000gen.${i##*.}"; done

    # Merge
    plink --bfile filt_tempdata --bmerge filt_1000gen --make-bed --out Data/$OUTPUT
fi 

# Remove 
rm -r *temp*
rm -r *filt*
rm -r *snps*

