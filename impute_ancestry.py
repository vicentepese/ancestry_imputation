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

    # Plot PCA

def main():

    # Read settings
    settings = pd.read_json("settings.json")

    # Merge data with CHR of 1000 Genome
    merge_data(settings)


if __name__ == "__main__":
    main()