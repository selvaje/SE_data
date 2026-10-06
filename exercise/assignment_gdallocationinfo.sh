##   Assignment:
##   use this code

# Create the lat long file

cd media/sf_LVM_shared/my_SE_data/exercise
echo 32.5 2.5 > geodata/LST/x_y.txt
echo 31.1 2.1 >> geodata/LST/x_y.txt
# looping trough the images
for file in geodata/LST/LST_MOYDmax_month?.tif geodata/LST/LST_MOYDmax_month??.tif; do
   gdallocationinfo -valonly -geoloc $file < geodata/LST/x_y.txt
   echo ""
done

## and modify it in such a way you get a table like this

## 32.5 2.5 37.4022827148438 40.3694458007812 38.5549926757812 32.7738952636719  ..... ......
## 31.1 2.1  35.0345764160156 37.824951171875  36.6663208007812  32.6803283691406 ..... ......

---
## Knowing that

gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month10.tif < geodata/LST/x_y.txt

## produce a column file:

28.8177490234375
29.066650390625

### we can use paste with all the files
paste -d " " geodata/LST/x_y.txt   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month1.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month2.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month3.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month4.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month5.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month6.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month7.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month8.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month9.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month10.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month11.tif < geodata/LST/x_y.txt) \
                                   <(gdallocationinfo -valonly -geoloc geodata/LST/LST_MOYDmax_month12.tif < geodata/LST/x_y.txt)

### or we can use the new gdal raster syntax

gdal raster pixel-info --position-crs EPSG:4326 -f CSV geodata/LST/LST_MOYDmax_month1.tif < geodata/LST/x_y.txt | awk -F , '{  if (NR>1) print $1 , $7}'

### wich produce

##  32.5 37.40228271484375
##  31.100000000000001 35.034576416015625

# and we can combine in the same way 

paste -d " " <(gdal raster pixel-info --position-crs EPSG:4326 -f CSV geodata/LST/LST_MOYDmax_month1.tif < geodata/LST/x_y.txt | awk -F , '{  if (NR>1) print $1 , $7}' ) <(gdal raster pixel-info --position-crs EPSG:4326 -f CSV geodata/LST/LST_MOYDmax_month2.tif < geodata/LST/x_y.txt | awk -F , '{  if (NR>1) print $7}'	)																		    

## and so on for the other files

gdal raster stack -f VRT --overwrite   geodata/LST/LST_MOYDmax_month1.tif geodata/LST/LST_MOYDmax_month2.tif geodata/LST/LST_MOYDmax_month.vrt 

gdal raster pixel-info --position-crs EPSG:4326 -f CSV geodata/LST/LST_MOYDmax_month.vrt  < geodata/LST/x_y.txt | awk -F , '{  if (NR>1) print $1, $7 , $9 }'

## 32.5 37.40228271484375 40.36944580078125
##  31.100000000000001 35.034576416015625 37.824951171875
