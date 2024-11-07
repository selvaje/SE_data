#!/bin/bash
#SBATCH -p normal
#SBATCH -J hpc02a_resampling_tif_forloop.sh
#SBATCH -N 1 -c 1 -n 1
#SBATCH -t 1:00:00 
#SBATCH -o /home/geocourse-teacher01/stdout/hpc02a_resampling_tif_forloop.sh.%J.out
#SBATCH -e /home/geocourse-teacher01/stderr/hpc02a_resampling_tif_forloop.sh.%J.err
#SBATCH --mem-per-cpu=8000

#### sbatch  /project/geocourse/Software/scripts/hpc02a_resampling_tif_forloop.sh

module load GDAL/3.3.2-foss-2021b

IN=/project/geocourse/Data/glad_ard 
OUT=/home/$USER/glad_ard

mkdir -p $OUT 
rm -f $OUT/SA_intra_res.tif $OUT/stack.vrt $OUT/SA_intra_LL_res.tif $OUT/SA_intra_LR_res.tif $OUT/SA_intra_UL_res.tif $OUT/SA_intra_UR_res.tif # remove the outputs
  
echo resampling the SA_intra_??.vrt files within a for loop 



for file in $OUT/SA_intra_??.vrt   ; do 
echo processing $file
filename=$(basename $file .vrt)
GDAL_CACHEMAX=5000
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -tr 0.002083333333333 0.002083333333333  -r bilinear  $file  $OUT/${filename}_res.tif 
done 

echo reassembling the large tif 

gdalbuildvrt -overwrite $OUT/stack.vrt   $OUT/SA_intra_LL_res.tif   $OUT/SA_intra_LR_res.tif     $OUT/SA_intra_UL_res.tif   $OUT/SA_intra_UR_res.tif
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUT/stack.vrt $OUT/SA_intra_res.tif 
rm -f $OUT/SA_intra_LL_res.tif   $OUT/SA_intra_LR_res.tif     $OUT/SA_intra_UL_res.tif   $OUT/SA_intra_UR_res.tif   $OUT/stack.vrt 



