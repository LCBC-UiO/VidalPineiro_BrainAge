#!/bin/bash 

#SBATCH --job-name=HyperParameterSearch
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=06:00:00
#SBATCH --account=p274
#SBATCH --output scripts/BrainAge/logs_RandomHyperParameterSearchCV/slurm-%j.txt
##SBATCH --partition=hugemem



######################
# setting environment
######################
echo "SETTING UP COLOSSUS ENVIRONMENT"
echo "LOADING SINGULARITY MODULE"
module purge
module load R/3.6.3-foss-2020a
echo `which R`
module load matlab
echo `which matlab`

echo "SOURCING FREESURFER"
export FREESURFER_HOME=/cluster/projects/p274/tools/mri/freesurfer/current
source $FREESURFER_HOME/SetUpFreeSurfer.sh
echo "SOURCING FSL"
FSLDIR=/cluster/projects/p274/tools/mri/fsl/current
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
export LANG=en_US.utf8

eta=${1}
max_depth=${2}
gamma=${3}
min_child_weight=${4}
nrounds=${5}
i=${6}
idx=${7}
data_folder=${8}
sex_split=${9}

echo "$eta $max_depth $gamma $min_child_weight $nrounds $i $idx $data_folder"
mv scripts/BrainAge/logs_RandomHyperParameterSearchCV/slurm-${SLURM_JOBID}.txt scripts/BrainAge/logs_RandomHyperParameterSearchCV/slurm.it.$i.txt

basefolder=/cluster/projects/p274/projects/p024-modes_of_variation
scriptsfolder=$basefolder/scripts/BrainAge

Rscript $scriptsfolder/RandomHyperParameterSearchCV.R $eta $max_depth $gamma $min_child_weight $nrounds $i $idx $data_folder $sex_split

