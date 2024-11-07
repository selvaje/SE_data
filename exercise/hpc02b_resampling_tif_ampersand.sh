#!/bin/bash
#SBATCH -p normal
#SBATCH -J hpc02b_resampling_tif_ampersand.sh
#SBATCH -N 1 -c 1 -n 4
#SBATCH --cpus-per-task=1
#SBATCH -t 1:00:00 
#SBATCH -o /home/geocourse-teacher01/stdout/hpc02b_resampling_tif_ampersand.sh.%J.out
#SBATCH -e /home/geocourse-teacher01/stderr/hpc02b_resampling_tif_ampersand.sh.%J.err
#SBATCH --mem-per-cpu=2000
	
#### sbatch  /project/geocourse/Software/scripts/hpc02b_resampling_tif_ampersand.sh

module load GDAL/3.3.2-foss-2021b
	
IN=/project/geocourse/Data/glad_ard 
OUT=/home/$USER/glad_ard
	
rm -f $OUT/SA_intra_res.tif $OUT/stack.vrt $OUT/SA_intra_LL_res.tif $OUT/SA_intra_LR_res.tif $OUT/SA_intra_UL_res.tif $OUT/SA_intra_UR_res.tif # remove the outputs
	
echo resampling the SA_intra_??.vrt files using the ampersand 
	
export GDAL_CACHEMAX=1500

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.002083333333333 0.002083333333333 -r bilinear $OUT/SA_intra_UL.vrt $OUT/SA_intra_UL_res.tif &
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.002083333333333 0.002083333333333 -r bilinear $OUT/SA_intra_UR.vrt $OUT/SA_intra_UR_res.tif &	
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.002083333333333 0.002083333333333 -r bilinear $OUT/SA_intra_LL.vrt $OUT/SA_intra_LL_res.tif &
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9 -tr 0.002083333333333 0.002083333333333 -r bilinear $OUT/SA_intra_LR.vrt $OUT/SA_intra_LR_res.tif &
wait 
		
echo reassembling the large tif 
	
gdalbuildvrt -overwrite $OUT/stack.vrt   $OUT/SA_intra_LL_res.tif   $OUT/SA_intra_LR_res.tif     $OUT/SA_intra_UL_res.tif   $OUT/SA_intra_UR_res.tif
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUT/stack.vrt $OUT/SA_intra_res.tif 
rm -f $OUT/SA_intra_LL_res.tif   $OUT/SA_intra_LR_res.tif     $OUT/SA_intra_UL_res.tif   $OUT/SA_intra_UR_res.tif   $OUT/stack.vrt
