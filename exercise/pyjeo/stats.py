import matplotlib.pyplot as plt
import pyjeo as pj

fn = '../geodata/temperature/ug_bio_3.tif'
jim = pj.Jim(fn)
stats = jim.stats.getStats('histogram', src_min = 0)
fn = '../geodata/vegetation/GPPstdev08-11.tif'
jim = pj.Jim(fn)
stats = jim.stats.getStats('histogram', src_min = 0, nbin = 20)
for index, bin in enumerate(stats['bin']):
    print(bin, stats['histogram'][index])

fig = plt.figure(figsize = (10, 5))
plt.bar(stats['bin'],stats['histogram'])
plt.xlabel("pixel value")
plt.ylabel("abs frequency")
plt.title("Histogram of pixel values")
plt.show()
