import pyjeo as pj


fn = '../geodata/vegetation/ETmean08-11.tif'
jim = pj.Jim(fn)

#get mask
mask1 = (jim>=1) & (jim<=2)
mask2 = (jim>=5) & (jim<=8)
mask3 = (jim<0) | (jim>10)

#set mask
jim[mask1] = -9
jim[mask2] = -5
jim[mask3] = -10

#we can do it at once:
jim = pj.Jim(fn)

jim[(jim<0) | (jim>10)] = -10
jim[(jim>=5) & (jim<=8)] = -5
jim[(jim>=1) & (jim<=2)] = -9

jim.io.write('ETmean08-11_01_msk.tif', co = ['COMPRESS=DEFLATE', 'ZLEVEL=9'])
