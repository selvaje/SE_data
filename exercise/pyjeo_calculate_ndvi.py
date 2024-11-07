from pathlib import Path
import shutil
import argparse
import pyjeo as pj

parser=argparse.ArgumentParser()
parser.add_argument("-input", "--input", help = "path of input image \
        containing the red and near infrared bands", dest = "input",
        required = True, type=str, default = 's2_composite.tif')
parser.add_argument("-output","--output",help="output path for calculated \
        NDVI image", dest = "output", required = True, type = str)
parser.add_argument("-tmpdir", "--tmpdir", help="Temporary directory",
        dest = "tmpdir", required = False, type = str, default = "")
parser.add_argument("-tileindex", "--tileindex", help = "tileindex \
        (from 0 to tiletotal-1)", dest = "tileindex", required = True, 
        type = int)
parser.add_argument("-tiletotal", "--tiletotal", help = "total number of \
        tiles to process (must be a square number, e.g., 64 (= 8**2)", 
        dest = "tiletotal", required = False, type = int)
parser.add_argument("-overwrite","--overwrite", help = "overwrite output",
        dest="overwrite",required = False, type = str,default = False)
parser.add_argument("-verbose", "--verbose", help = "verbose output",
        dest = "verbose", required = False, type = str, default = False)

args = parser.parse_args()

tmpDir = Path(args.tmpdir)

raster_path = Path(args.input)

jim = pj.Jim(Path(args.input), tileindex = args.tileindex, 
        tiletotal = args.tiletotal)
jim.properties.setDimension(['B04', 'B08'], 'band')
if args.verbose:
    print(jim.properties.getDimension())
    #print(jim.xr())
jim.pixops.NDVI(red = 'B04', nir = 'B08', scale = 100, offset = 0, 
        name = 'NDVI', nodata = 255)
if args.verbose:
    print(jim.properties.getDimension())
    #print(jim.xr())

outputname = (Path(args.output).name + '_' + str(args.tileindex) + '_' + \
        str(args.tiletotal) + Path(args.output).suffix)

output = Path(Path(args.output).parent) / outputname
tmpoutput = Path(args.tmpdir) / outputname

if args.verbose:
    print("writing temporary output {}".format(tmpoutput))
jim.io.write(tmpoutput, co = ['COMPRESS=LZW', 'TILED=YES'])
if args.verbose:
    print("copying temporary output to {}".format(output))
shutil.copy(tmpoutput, output)
if args.verbose:
    print("removing temporary output {}".format(tmpoutput))
tmpoutput.unlink()
