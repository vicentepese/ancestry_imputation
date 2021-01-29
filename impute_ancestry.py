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

    # Merge data through PLINK 
    subprocess.call('bash sh_scripts/merge_bed.sh', shell = True)

def compute_pca(settings):

    # Compute PCA 
    subprocess.call('bash sh_scripts/pca.sh' , shell = True)

def compute_ethnicity(settings):

    # Read PCA 
    PCA = pd.read_csv(settings.Resources.PCA_eigenvec, header = None, delim_whitespace = True)
    PCA.columns = ['FID', 'IID'] + ['PC' + str(x) for x in range(1,21)]

    # Read 1000 Genome Ethnicity 
    thougen_ethn = pd.read_csv(settings.Resources.thougen_ethnicity, header = 0)

    # Get PCA from 1000 Genome and compute average by etnicity
    mu_eth = pd.DataFrame()
    PCA_genome = PCA[PCA.IID.isin(thougen_ethn.Sample)]
    for eth in thougen_ethn.Population.unique():

        # Get PCAs from ethnicity
        PCA_eth = PCA_genome[PCA_genome.IID.isin(thougen_ethn[thougen_ethn.Population.eq(eth)].Sample)]

        # Compute mean of PC1 and PC2
        PC1_mu, PC2_mu = PCA_eth.PC1.mean(), PCA_eth.PC2.mean()

        # Append to dataframe 
        mu_eth[eth] = [PC1_mu, PC2_mu]

    # Initialize for loop
    PCA_subj = PCA[~PCA.IID.isin(thougen_ethn.Sample)]
    subj_eth = pd.DataFrame(columns= ["FID", "IID", "ethnicity"])
    for idx, value in PCA_subj.iterrows():

        # Compute Eucliden distance to each ethnicity 
        dist_subj_eth = list()
        for eth in mu_eth.columns:

            # Compute euclidean distance and append
            dist_subj_eth.append(euclidean(value[["PC1", "PC2"]], mu_eth[eth]))

        # Append ethnicity
        subj_eth = subj_eth.append(pd.DataFrame({"FID": [value.FID], "IID": [value.IID], \
                "ethnicity": [mu_eth.columns[dist_subj_eth.index(min(dist_subj_eth))]]}), ignore_index=True)

    # Write ethnicity
    subj_eth.to_csv(settings.Resources.data_ethnicity, sep = ",", header=True)


def plot_pca(settings):

    # Read PCs
    PCA = pd.read_csv(settings.Resources.PCA_eigenvec, header = None, delim_whitespace = True)
    PCA.columns = ['FID', 'Sample'] + ['PC' + str(x) for x in range(1,21)]

    # Read Ethnicity and concat
    thougen_ethn = pd.read_csv(settings.Resources.thougen_ethnicity, header = 0)
    data_ethn = pd.read_csv(settings.Resources.data_ethnicity, header = 0)
    ethnicity = pd.concat([thougen_ethn, data_ethn], ignore_index=True, sort = False)

    # Merge with PCA
    PCA = pd.merge(PCA, ethnicity[['Sample', 'Population']], on='Sample')
    PCA = PCA[PCA.Sample.isin(thougen_ethn.Sample)]

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

    # Merge data with CHR of 1000 Genome
    merge_data(settings)

    # Compute PCA
    compute_pca(settings)

    # Compute etnicities
    compute_ethnicity(settings)

    # Plot PCA
    plot_pca(settings)


if __name__ == "__main__":
    main()