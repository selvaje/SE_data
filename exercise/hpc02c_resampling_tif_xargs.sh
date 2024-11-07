#!/bin/bash
#SBATCH -p normal
#SBATCH -J hpc02c_resampling_tif_xargs.sh
#SBATCH -n 1 -c 4 -N 1
#SBATCH -t 1:00:00 
#SBATCH -o /home/geocourse-teacher01/stdout/hpc02c_resampling_tif_xargs.sh.%J.out
#SBATCH -e /home/geocourse-teacher01/stderr/hpc02c_resampling_tif_xargs.sh.%J.err
#SBATCH --mem-per-cpu=2000

#### sbatch /project/geocourse/Software/scripts/hpc02c_resampling_tif_xargs.sh

module load GDAL/3.3.2-foss-2021b

export IN=/project/geocourse/Data/glad_ard 
export OUT=/home/$USER/glad_ard

mkdir -p $OUT
rm -f $OUT/SA_intra_res.tif $OUT/stack.vrt $OUT/SA_intra_LL_res.tif $OUT/SA_intra_LR_res.tif $OUT/SA_intra_UL_res.tif $OUT/SA_intra_UR_res.tif # remove the outputs

echo resampling the SA_intra_??.vrt files within a multicore loop 

ls $OUT/SA_intra_??.vrt | xargs -n 1 -P 4 bash -c $'  
file=$1
echo processing $file
filename=$(basename $file .vrt)
export GDAL_CACHEMAX=1500
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -tr 0.002083333333333 0.002083333333333  -r bilinear  $file  $OUT/${filename}_res.tif
' _ 

echo reassembling the large tif 

gdalbuildvrt -overwrite $OUT/stack.vrt   $OUT/SA_intra_LL_res.tif   $OUT/SA_intra_LR_res.tif     $OUT/SA_intra_UL_res.tif   $OUT/SA_intra_UR_res.tif
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUT/stack.vrt $OUT/SA_intra_res.tif
rm -f $OUT/SA_intra_LL_res.tif $OUT/SA_intra_LR_res.tif $OUT/SA_intra_UL_res.tif $OUT/SA_intra_UR_res.tif $OUT/stack.vrt
