#!/bin/bash
#SBATCH -p normal
#SBATCH -J hpc02d_resampling_tif_njobs.sh
#SBATCH -N 1 -c 1 -n 1
#SBATCH -t 1:00:00 
#SBATCH -o /home/geocourse-teacher01/stdout/hpc02d_resampling_tif_njobs.sh.%J.out
#SBATCH -e /home/geocourse-teacher01/stderr/hpc02d_resampling_tif_njobs.sh.%J.err
#SBATCH --mem-per-cpu=8000

#### for file in /home/$USER/glad_ard/SA_intra_??.vrt ; do sbatch --export=file=$file /project/geocourse/Software/scripts/hpc02d_resampling_tif_njobs.sh ; done 

module load GDAL/3.3.2-foss-2021b

export IN=/project/geocourse/Data/glad_ard 
export OUT=/home/$USER/glad_ard

mkdir -p $OUT
rm -f $OUT/SA_intra_res.tif $OUT/stack.vrt # remove the outputs

echo resampling the $file  files with an indipendent job 

filename=$(basename $file .vrt)
export GDAL_CACHEMAX=5000
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -tr 0.002083333333333 0.002083333333333  -r bilinear  $file  $OUT/${filename}_res.tif

#### reassembling the large tif

if [ $filename = SA_intra_UR ]  ; then
    sleep 60 # to be sure that all the other job are done 
    echo reassembling the large tif
    gdalbuildvrt -overwrite $OUT/stack.vrt   $OUT/SA_intra_LL_res.tif   $OUT/SA_intra_LR_res.tif     $OUT/SA_intra_UL_res.tif   $OUT/SA_intra_UR_res.tif
    gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUT/stack.vrt $OUT/SA_intra_res.tif
    rm -f $OUT/SA_intra_LL_res.tif $OUT/SA_intra_LR_res.tif $OUT/SA_intra_UL_res.tif $OUT/SA_intra_UR_res.tif $OUT/stack.vrt
fi 





