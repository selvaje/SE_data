#for ((TILE=0;TILE<4;++TILE));do echo $TILE;done | parallel time python3 composite_tiling.py -tileindex {} -tiletotal 4 -overlap 0 -output /tmp/test_{}.tif
from pathlib import Path
import argparse
import pyjeo as pj

parser=argparse.ArgumentParser()
parser.add_argument("-output","--output",help="output path",dest="output",required=True,type=str)
parser.add_argument("-tileindex","--tileindex",help="tileindex to split input",dest="tileindex",required=False,type=int,default=None)
parser.add_argument("-tiletotal","--tiletotal",help="total to split input",dest="tiletotal",required=False,type=int,default=None)
parser.add_argument("-overlap","--overlap",help="overlap when tiling",dest="overlap",required=False,type=float,default=0)

args = parser.parse_args()

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
        jim = pj.Jim(file, tileindex = args.tileindex, tiletotal = args.tiletotal, overlap = args.overlap)
        print(jim.properties.nrOfCol())
        mask = (jim >= 0) & (jim <= 25)
    else:
        jim1 = pj.Jim(file, tileindex = args.tileindex, tiletotal = args.tiletotal, overlap = args.overlap)
        print(jim1.properties.nrOfCol())
        jim.geometry.stackPlane(jim1)
for file in files2:
    print(file)
    jim1 = pj.Jim(file, tileindex = args.tileindex, tiletotal = args.tiletotal, overlap = args.overlap)
    print(jim1.properties.nrOfCol())
    jim.geometry.stackPlane(jim1)

print(jim.properties.nrOfPlane())

jim[mask] = 0
mean = pj.geometry.reducePlane(jim, rule = 'mean', nodata = 0)
mean.io.write(args.output)
