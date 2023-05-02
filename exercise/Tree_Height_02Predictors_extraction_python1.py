#!/usr/bin/env python3
#
# This is the whole script written in a proper way to work even in bash.
# You can copy&paste this block in a text `whatever.py` file, then
# chmod a+x whatever.py 
# and run it as ./whatever.py 
#

import csv
import glob
import rasterio
import os.path

files = []
for filename in glob.glob('tree_height/geodata_raster/[!l]*.tif'):
    ds = rasterio.open(filename, mode='r')
    files.append(ds)

(name, ext) = os.path.splitext(os.path.basename(files[0].name))
header = ''
for ds in files:
    field_name = os.path.splitext(os.path.basename(ds.name))[0]
    header += ' '+field_name

print('Reading raster files...')

bands = []
for ds in files:
    bands.append(ds.read(1))

print('Writing samples')

with open('tree_height/txt/eu_x_y_predictors_select_new.txt', 'w') as out:
    print('ID X Y' + header, file=out)
    with open('tree_height/txt/eu_x_y_select.txt') as csvfile:
        coords = csv.reader(csvfile, delimiter=' ')
        i = 1
        for (long, lat) in coords:
            print('{} {} {} '.format(i, long, lat),end='', file=out)
            for j, ds in enumerate(files):
                idx = ds.index(float(long), float(lat))
                band = bands[j]
                val = band[idx]
                print('{} '.format(val), end='', file=out)
            print("", file=out)
            if not i % 10: print('Record {} ...'.format(i))
            i+=1
    csvfile.close()
out.close()

print('Finished')

exit(0)
