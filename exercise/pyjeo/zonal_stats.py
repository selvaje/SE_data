from pathlib import Path
import pandas as pd
import pyjeo as pj

fn = '../geodata/vegetation/GPPmean08-11.tif'
vfn = '../geodata/shp/polygons.sqlite'
jim = pj.Jim(fn)
jim[jim<0]=-1
print(jim.stats.getStats())
v = pj.JimVect(vfn)
print("extracting in SQLite format")
output = '../geodata/shp/temp.sqlite'
Path(output).unlink(missing_ok = True)
extracted1 = pj.geometry.extract(v, jim, rule=['mean', 'stdev', 'min'], output=output, srcnodata = -1)
print("extracting in ESRI Shape format")
output = '../geodata/shp/temp.shp'
Path(output).unlink(missing_ok = True)
extracted2 = pj.geometry.extract(v, jim, rule=['mean', 'stdev', 'min'], output='../geodata/shp/temp.shp', oformat='ESRI Shapefile', srcnodata = -1)

print("calculate in memory and get result in dictionary")
extracted3 = pj.geometry.extract(v, jim, rule=['mean', 'stdev', 'min'], output='/vsimem/temp1.sqlite', oformat='SQLite', srcnodata = -1)
print(extracted3.dict())
print("In pandas format")
print(pd.DataFrame(extracted3.dict()))
print("Extract point data")
vfn = '../geodata/shp/presence.shp'
v = pj.JimVect(vfn)
extracted4 = pj.geometry.extract(v, jim, rule=['allpoints'], output='/vsimem/point.sqlite', oformat='SQLite', srcnodata = -1)
print("Extract points with buffer to calculate mean and standard deviation and minimum")
buffer = jim.properties.getDeltaX()*1
extracted5 = pj.geometry.extract(v, jim, rule=['mean', 'stdev', 'min'], output='/vsimem/point_buf.sqlite', oformat='SQLite', srcnodata = -1, buffer = buffer)
print("In pandas format")
print(pd.DataFrame(extracted5.dict()))
