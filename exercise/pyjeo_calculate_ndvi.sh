#!/bin/bash
#SBATCH -p normal
#SBATCH --reservation=geo_course_cpu
#SBATCH -J pyjeo_calculate_ndvi.sh
#SBATCH -N 1 -c 1 -n 1
#SBATCH -t 1:00:00 
#SBATCH -o /home/geocourse-teacher01/stdout/pyjeo_calculate_ndvi.sh.%J.out
#SBATCH -e /home/geocourse-teacher01/stderr/pyjeo_calculate_ndvi.sh.%J.err
#SBATCH --mem=500
#SBATCH --array=1-64

mkdir -p $HOME/Data

module load Python/3.9.6-GCCcore-11.2.0
module load LibTIFF/4.3.0-GCCcore-11.2.0
module load libgeotiff/1.7.0-GCCcore-11.2.0
module load uthash/2.3.0-foss-2021b
module load shapelib/1.6.0-foss-2021b
module load GSL/2.7-GCC-11.2.0
module load GDAL/3.3.2-foss-2021b
module load jsoncpp/1.9.5-foss-2021b
module load fann/2.2.0-foss-2021b
module load SWIG/4.2.1-foss-2021b

export PYTHONPATH=""
source $HOME/pyjeo-venv/bin/activate


python3 $HOME/scripts/pyjeo_calculate_ndvi.py -input /project/geocourse/Data/pyjeo/s2_composite.tif -output $HOME/Data/ndvi.tif  -tiletotal 64 -tileindex $SLURM_ARRAY_TASK_ID   -tmpdir $TMPDIR -verbose True

