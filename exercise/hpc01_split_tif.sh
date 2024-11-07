#!/bin/bash
#SBATCH -p normal
#SBATCH -J hpc01_split_tif.sh
#SBATCH -N 1 -c 1 -n 1
#SBATCH -t 1:00:00 
#SBATCH -o /home/geocourse-teacher01/stdout/hpc01_split_tif.sh.%J.out
#SBATCH -e /home/geocourse-teacher01/stderr/hpc01_split_tif.sh.%J.err
#SBATCH --mem=500

#### sbatch /project/geocourse/Software/scripts/hpc01_split_tif.sh

module load GDAL/3.3.2-foss-2021b

IN=/project/geocourse/Data/glad_ard
OUT=/home/$USER/glad_ard
mkdir -p $OUT

gdal_translate -of VRT  -srcwin 0       0 2940 4200 $IN/SA_intra.tif $OUT/SA_intra_UL.vrt 
gdal_translate -of VRT  -srcwin 0    4200 2940 4200 $IN/SA_intra.tif $OUT/SA_intra_UR.vrt 
gdal_translate -of VRT  -srcwin 2940    0 2940 4200 $IN/SA_intra.tif $OUT/SA_intra_LL.vrt 
gdal_translate -of VRT  -srcwin 2940 4200 2940 4200 $IN/SA_intra.tif $OUT/SA_intra_LR.vrt   
