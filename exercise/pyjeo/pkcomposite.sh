#!/bin/bash
pkgetmask  -co COMPRESS=DEFLATE -co ZLEVEL=9 -min 0 -max 25 -data 0 -nodata 1 -ot Byte -i ../geodata/LST/LST_MOYDmax_month1.tif -o ../geodata/LST/LST_MOYDmax_month1-msk.tif
pkcomposite $(for file in ../geodata/LST/LST_MOYDmax_month?.tif ../geodata/LST/LST_MOYDmax_month??.tif; do echo -i $file; done) \
            -m ../geodata/LST/LST_MOYDmax_month1-msk.tif -msknodata 0 -cr mean   -dstnodata 0 \
            -co  COMPRESS=LZW -co ZLEVEL=9 -o ../geodata/LST/LST_MOYDmax_monthMean.tif

pkcomposite $(for file in  ../geodata/LST/LST_MOYDmax_month?.tif ../geodata/LST/LST_MOYDmax_month??.tif; do echo -i $file; done) \
            -m ../geodata/LST/LST_MOYDmax_month1-msk.tif -msknodata 0 -cr stdev   -dstnodata -1 \
            -co  COMPRESS=LZW -co ZLEVEL=9 -o ../geodata/LST/LST_MOYDmax_monthStdev.tif
