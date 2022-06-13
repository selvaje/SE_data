import matplotlib.pyplot as plt
import numpy as np
import pyjeo as pj

fn = '../geodata/temperature/ug_bio_3.tif'
jim = pj.Jim(fn)
print(jim.properties.getDataType())
print(jim.stats.getStats())
stats = jim.stats.getStats('histogram')

for index, bin in enumerate(stats['bin']):
    if stats['histogram'][index] > 0:
        print(bin, stats['histogram'][index])

if -9999 in jim.np():
    print("value -9999 is found")
classes0 = [c for c in stats['bin'] if stats['histogram'][stats['bin'].index(c)] > 0 and c < 75]
classes1 = [c for c in stats['bin'] if stats['histogram'][stats['bin'].index(c)] > 0 and c >= 75]
reclasses0 = np.zeros_like(classes0).tolist()
reclasses1 = np.ones_like(classes1).tolist()
print(classes0 + classes1)
# print(classes1)
print(reclasses0 + reclasses1)
# print(reclasses1)

reclass = pj.classify.reclass(jim, classes = classes0 + classes1, reclasses = reclasses0 + reclasses1)

# however, we can do it much simpler:
jim[jim < 75] = 0
jim[jim >= 75] = 1
print(reclass.properties.isEqual(jim))
