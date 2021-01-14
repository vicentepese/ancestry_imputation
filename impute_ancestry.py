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
    subprocess.call('bash ' + settings.sh_scripts.merge, shell = True)

def compute_pca(settings):

    # Compute PCA 
    subprocess.call('bash' + settings.sh_scripts.pca, shell = True)

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

    # Plot PCs
    sns.color_palette("tab10")
    ax = sns.relplot(data=PCA, x = 'PC1', y = 'PC2', hue = "Population", \
        palette=sns.color_palette('bright', n_colors=PCA['Population'].nunique()))
    ax.set(xlabel = "PC1", ylabel = "PC2", title = "PCA")
    plt.show()


def main():

    # Read settings
    settings = pd.read_json("settings.json")

    # Merge data with CHR of 1000 Genome
    merge_data(settings)

    # Compute PCA
    compute_pca(settings)

    # Plot PCA
    plot_pca(settings)


if __name__ == "__main__":
    main()