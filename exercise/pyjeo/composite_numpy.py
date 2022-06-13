from pathlib import Path
import numpy as np
import pyjeo as pj

#create mean and standard deviation of multi-plane images that is masked

# import required module

# assign directory
directory = 'files'

# iterate over files in
# that directory
files1 = sorted(Path('../geodata/LST/').glob('LST_MOYDmax_month?.tif'))
files2 = sorted(Path('../geodata/LST/').glob('LST_MOYDmax_month??.tif'))

#create single band multi-plane image
mask = None
jim = None
for file in files1:
    print(file)
    if jim is None:
        jim = pj.Jim(file)
        mask = (jim >= 0) & (jim <= 25)
    else:
        jim.geometry.stackPlane(pj.Jim(file))
for file in files2:
    print(file)
    jim.geometry.stackPlane(pj.Jim(file))

print(jim.properties.nrOfPlane())

jim[mask] = 0
mask.pixops.convert(jim.properties.getDataType())
jim.np()[jim.np()==0] = np.nan

mask.np()[:] = np.nanmean(jim.np(), axis=0)
mask.geometry.stackBand(mask)
mask.np(1)[:] = np.nanstd(jim.np(), axis=0)

#to avoid NaN, replace with 0
# mask.np()[:] = np.nan_to_num(np.nanmean(jim.np(), axis=0), nan=0)
# mask.geometry.stackBand(mask)
# mask.np(1)[:] = np.nan_to_num(np.nanstd(jim.np(), axis=0), nan=0)
#even better, avoid duplication of data to reduce memory footprint
# mask.np()[:] = np.nan_to_num(np.nanmean(jim.np(), axis=0), copy = False, nan=0)
# mask.geometry.stackBand(mask)
# mask.np(1)[:] = np.nan_to_num(np.nanstd(jim.np(), axis=0), copy = False, nan=0)

