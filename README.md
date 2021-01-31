# Anecstry Imputation


## Introduction 
This repository attempts to impute the ethnicity provided a set of binary PLINK files. It utilizes the [1000 Genomes Phase 3 Data](https://www.internationalgenome.org/data) and its [Associated Data](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3). 

Nonetheless, the 1000 Genome Data was Quality Controlled (QC) prior to be used in this repository, removing multiallelic variants. The data can be request to [Aditya Ambassi](https://github.com/adiamb) - otherwise, please proceed to download the 1000 Genomes variants data and perform a QC routine to remove undesired and multiallelic variants.

## Pipeline

The pipeline is composed by three main steps:
1. **Merge**: common Single Nucleotides Polymorphisms (SNP) are parsed in chromosome 2 and 3, and the data provided is merged with the 1000 Genomes variants data.