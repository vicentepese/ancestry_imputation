#!/usr/bin/env python
"""Computes ethnicity by mapping chromsomes 2 and 3 to 1000 Genome

- Merges data and 1000 Genomes .bed files taking common SNPs of CHR 2 and 3
    based on position.
- Computes Principal Component Analysis (PCA)
- Computes the Euclidean distance of each subject's PC1 and PC2, to the 
    mean of PCs of each 1000 Genome ethnicity (each ethnicity has a "mean").
- The closest ethnicity mean is considered as the ethnicity of the subject.
- Plots PCA based on ethnicity.

NOTE: Some subjects from 1000 Genome may be labeled as an etnicity, far from the mean.
"""

__author__ = "Vicente Peris Sempere"
__credits__ = ["Vicente Peris Sempere"]
__license__ = "GPL"
__version__ = "3.0"
__maintainer__ = "Vicente Peris Sempere"
__email__ = "vipese@stanford.edu"
__status__ = "Finalized"

import numpy as np
import subprocess
import json
import os
from os.path import isfile, join
from collections import defaultdict, OrderedDict
import matplotlib.pyplot as plt
import scipy 
from scipy.spatial.distance import euclidean 
import seaborn as sns
import pandas as pd

def merge_data(settings):
    """ Calls a bash script that merges the data throuh PLINK
    Input:
        - settings: settings JSON file
    Output:
        - Merged files (Data folder)
    """

    # Merge data through PLINK 
    subprocess.call('bash sh_scripts/merge_bed.sh', shell = True)

def compute_pca(settings):
    """Calls a bash script that computes PCA through PLINK
    Input:
        - settings: settings JSON file
    Output:
        - PCs (Resources folder)
    """

    # Compute PCA 
    subprocess.call('bash sh_scripts/pca.sh' , shell = True)

def compute_ethnicity(settings):
    """ Computes etnicity as the closest euclidean distance of each 
        subject's PCs to each 1000 Genome PCs ethnicity mean.
    Inputs: 
        - settings: settings JSON file 
    Outputs:
        - Ethnicity of Input Data (Resources folder) 
    """

    # Read PCA 
    PCA = pd.read_csv(settings.Resources.PCA_eigenvec, header = None, delim_whitespace = True)
    PCA.columns = ['FID', 'IID'] + ['PC' + str(x) for x in range(1,21)]

    # Read 1000 Genome Ethnicity 
    thougen_ethn = pd.read_csv(settings.Resources.thougen_ethnicity, header = 0)

    # Get PCA from 1000 Genome and compute average by etnicity
    mu_eth = pd.DataFrame()
    PCA_genome = PCA[PCA.IID.isin(thougen_ethn.IID)]
    for eth in thougen_ethn.Population.unique():

        # Get PCAs from ethnicity
        PCA_eth = PCA_genome[PCA_genome.IID.isin(thougen_ethn[thougen_ethn.Population.eq(eth)].IID)]

        # Compute mean of PC1 and PC2
        PC1_mu, PC2_mu = PCA_eth.PC1.mean(), PCA_eth.PC2.mean()

        # Append to dataframe 
        mu_eth[eth] = [PC1_mu, PC2_mu]

    # Initialize for loop
    PCA_subj = PCA[~PCA.IID.isin(thougen_ethn.IID)]
    subj_eth = pd.DataFrame(columns= ["FID", "IID", "Population"])
    for idx, value in PCA_subj.iterrows():

        # Compute Eucliden distance to each ethnicity 
        dist_subj_eth = list()
        for eth in mu_eth.columns:

            # Compute euclidean distance and append
            dist_subj_eth.append(euclidean(value[["PC1", "PC2"]], mu_eth[eth]))

        # Append ethnicity
        subj_eth = subj_eth.append(pd.DataFrame({"FID": [value.FID], "IID": [value.IID], \
                "Population": [mu_eth.columns[dist_subj_eth.index(min(dist_subj_eth))]]}), ignore_index=True)

    # Write ethnicity
    subj_eth.to_csv(settings.Resources.data_ethnicity, sep = ",", header = True, index = False)


def plot_pca(settings):
    """ Plots the PCs of merged data, and colors by ethnicity.
    Input:
        - settings: settings JSON file 
    Output:
        - PCA plot (ancestry_PCA.png)
    """

    # Read PCs
    PCA = pd.read_csv(settings.Resources.PCA_eigenvec, header = None, delim_whitespace = True)
    PCA.columns = ['FID', 'IID'] + ['PC' + str(x) for x in range(1,21)]

    # Read Ethnicity and concat
    thougen_ethn = pd.read_csv(settings.Resources.thougen_ethnicity, header = 0)
    data_ethn = pd.read_csv(settings.Resources.data_ethnicity, header = 0)
    ethnicity = pd.concat([thougen_ethn, data_ethn[["IID", "Population"]]], ignore_index=True, sort = False)

    # Merge with PCA
    PCA = pd.merge(PCA, ethnicity[['IID', 'Population']], on='IID')
    
    # Plot PCs
    sns.color_palette("tab10")
    ax = sns.relplot(data=PCA, x = 'PC1', y = 'PC2', hue = "Population", \
        palette=sns.color_palette('bright', n_colors=PCA['Population'].nunique()))
    ax.set(xlabel = "PC1", ylabel = "PC2", title = "PCA")
    plt.show()
    ax.savefig("ancestry_PCA.png")


def main():

    # Read settings
    settings = pd.read_json("settings.json")

    # # Merge data with CHR of 1000 Genome
    # merge_data(settings)

    # # Compute PCA
    # compute_pca(settings)

    # # Compute etnicities
    # compute_ethnicity(settings)

    # Plot PCA
    plot_pca(settings)


if __name__ == "__main__":
    main()