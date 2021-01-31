# Ancestry Imputation

## Requirements
This pipeline requires: 
> python 3.6.8 or higher
> plink 1.90 

## Introduction 
This repository attempts to impute the ethnicity provided a set of binary PLINK files. It utilizes the [1000 Genomes Phase 3 Data](https://www.internationalgenome.org/data) and its [Associated Data](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3). 

Nonetheless, the 1000 Genome Data was Quality Controlled (QC) prior to be used in this repository, removing multiallelic variants. The data can be request to [Aditya Ambassi](https://github.com/adiamb) - otherwise, please proceed to download the 1000 Genomes variants data and perform a QC routine to remove undesired and multiallelic variants.

## Pipeline

The pipeline is composed by three main steps:
1. **Merge**: common Single Nucleotides Polymorphisms (SNP) are parsed in chromosome 2, and the data provided is merged with the 1000 Genomes variants data. In the process, multiallelic and flipped variants are removed. 
2. **Principal Component Analysis**: PCA is computed to find directions of maximum variability.
3. **Ethnicity Computation**: The mean Principal Components (PC) of each 1000 Genome ethnicity is computed. Subsequently, each subjects PCs' euclidean distance to each 1000 Genome Ethnicity ethnicity mean is computed - the closest mean, is considered the ethnicity of the subject.
4. **Plot**: PCs of subjects and 1000 Genome subjects are ploted and colored by ethnicity.

## Utilization

To run the pipeline, please follow the next steps:
1. Copy the input data to the *Data* folder.
2. Copy the 1000 Genome binary PLINK files to the *Resources* folder.
3. Fill the `settings.json` file according the Settings section.
4. Run `python impute_ancestry.py`

### Settings
Please fill up the following items in `settings.json`:
* ***Resources***
  * *CHR2_1000Genome*: Relative or full path to the binary PLINK files of 1000 Genomes (*without extension, only the prefix*).
* ***Data***:
  * *prefix*: Prefix/name of the input data.

## Utils

### `parse_superpopulations.R`

This function is designed to parse the 1000 Genome superpopulations based on the  [Associated Data](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3). The function does not need to be ran, given that superpopulations have been provided in the pipeline and are located in the *Resources* folder. 

## Warnings and Future Work 

The pipeline does not currently support flipping variants. Multiallelic and flipped variants are removed.