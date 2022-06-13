from pathlib import Path
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
mean = pj.geometry.reducePlane(jim, rule = 'mean', nodata = 0)
