# Read settings
DATA=$(jq -r '.Data.data_prefix' settings.json)
THOU_DATA=$(jq -r '.Resources.CHR2_1000Genome' settings.json)
OUTPUT=$(jq -r '.Data.merged_data' settings.json)

# Decompress 1000 Genome data
plink2 --zst-decompress $THOU_DATA.pgen.zst > $THOU_DATA.pgen
plink2 --zst-decompress $THOU_DATA.pvar.zst > $THOU_DATA.pvar

# Convert to binary ped
plink2 --pfile $THOU_DATA --make-bed --rm-dup --out tst

# Merge 
plink --bfile $DATA --pmerge $THOU_DATA --make-bed --out tst 



########### SCRATCH 3###########

# Convert to VCF
plink2 --pfile $THOU_DATA --export vcf --out $THOU_DATA

# Remove non-biallelic variants

# Parse multiallelic
awk -F '\t' 'seen[$2]++' $THOU_DATA.pvar > temp

awk -F '\t' '{
    print $3
}' temp > multiallelic.txt
sed -i '/^$/d' multiallelic.txt
awk '!seen[$1]++' multiallelic.txt  > tst  && mv tst multiallelic.txt  
multiallele_exclude=$( awk '{ORS=", "}; {print $0}' multiallelic.txt)
rm temp 

# Exclude multiallelic
plink2 --pfile $THOU_DATA --exclude-snps $multiallele_exclude --rm-dup exclude-all --make-bed --out tst