#!/usr/bin/env python
# coding: utf-8

"""
Modification of the RasterIO Final Script for Preparing the Dataset for the Next ML Exercise 

Hannah Weiser, 2023-04-22
"""

# Imports
from pathlib import Path
import rasterio as rio
import numpy as np
import time

start = time.time()
print("Start processing ...")

# Create a list of (opened) raster datasets and of the corresponding field names
datasets = []
fieldnames = []
for filename in Path('tree_height/geodata_raster/').glob('[!l]*.tif'):
    ds = rio.open(filename, mode='r')
    datasets.append(ds)
    fieldnames.append(filename.stem)

# Read the coordinates to a numpy array
coords = np.genfromtxt('tree_height/txt/eu_x_y_select.txt', delimiter=' ')

# Create a dictionary with an array of pixel values at the coordinates for each field (i.e. values sampled from each raster)
raster_val_dict = {}
for i, ds in enumerate(datasets):
    # transform coordinates to raster row and column indices
    rows, cols = rio.transform.rowcol(ds.transform, coords[:, 0], coords[:, 1])
    rowcols = np.array(list(zip(rows, cols)))
    # read band of raster
    band = ds.read(1)
    # get values by indexing band with row and column indices
    vals = np.array([band[row, col] for row, col in rowcols])
    # add value array to dictionary
    raster_val_dict[fieldnames[i]] = vals
    ds.close()

# get keys from dictionary
keys = raster_val_dict.keys()
# add keys (=field names) to string which starts with "ID, Longitude and Latitude"
header = f"ID X Y {' '.join(keys)}"


# Create a 2D array with the indixes, coordinates and corresponding raster values for each sampled point

# get all arrays from dictionary as list
all_vals = list(raster_val_dict.values())
# get index, x-coordinate and y-coordinate as list and add the value arrays to that list
all_vals = [np.arange(1, coords.shape[0]+1), coords[:, 0], coords[:, 1]] + all_vals

# stack all arrays to a 2D array
all_vals_arr = np.hstack([all_vals]).T

end_operation = time.time()
print(f"Done in {end_operation-start:.1f} sec., Writing output file...")

# Write the array to a txt-file

# define the format of each column
fmt = '%u %.6f %.6f %u %u %u %u %.6f %i %.8f %.8f %.5f %u %.6f %.6f %.6f %.8f %u %u %.6f %.4f %i'
# save
np.savetxt('tree_height/txt/eu_x_y_predictors_select_python2.txt', all_vals_arr, fmt=fmt, delimiter=" ", header=header, comments='')

# depending on how we process the data later on, we could also use np.save() to save the array to a binary format

end = time.time()

print(f"Done. Writing took {end-end_operation:.1f} sec. Full script took {end-start:.1f}")
