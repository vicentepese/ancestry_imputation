

# Read settings
DATA=$(jq -r '.Data.data_prefix' settings.json)
THOU_DATA=$(jq -r '.Resources.CHR2_1000Genome' settings.json)
OUTPUT=$(jq -r '.Data.merged_data' settings.json)

# Compute PCA excluding by IBD, missingness, and HLA region
plink --bfile $OUTPUT \
    --allow-no-sex \
    --pca 20  --out pca
