import time
import numpy as np
from datetime import datetime
from pathlib import Path
import shutil
import argparse
import pyjeo as pj

parser=argparse.ArgumentParser()
parser.add_argument("-vector", "--vector", help = "path of vector file \
        containing polygons", dest = "vector",
        required = True, type=str, default = '/project/geocourse/Data/pyjeo/parcels_3035.shp')
parser.add_argument("-raster", "--raster", help = "path of raster image \
        containing the red and near infrared bands", dest = "raster",
        required = True, type=str, default = '/project/geocourse/Data/pyjeo/s2_crop.tif')
parser.add_argument("-verbose", "--verbose", help = "verbose output",
        dest = "verbose", required = False, type = str, default = False)

args = parser.parse_args()


start_time = datetime.now()
jim = pj.Jim(args.raster, band = 0)
v = pj.JimVect(args.vector)
extract = pj.geometry.extract(v,
                              jim,
                              rule=["mean", "stdev", "sum"],
                              output="/vsimem/pj.json",
                              oformat="GeoJSON",
                              )

if args.verbose:
    print("Processed {} polygons".format(extract.properties.getFeatureCount()))
secs_taken = (datetime.now() - start_time).total_seconds()
print("Time: {}".format(secs_taken))

