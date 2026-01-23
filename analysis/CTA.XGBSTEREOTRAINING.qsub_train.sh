#!/bin/bash
#
# train XGB stereo for CTA
#

ODIR=OUTPUTDIR
LLIST=MSCWLIST
DSET="DATASET"
env_name="eventdisplay_ml_cta"
P="0.5"
N="5000000"
MAXCORES=64

# set environmental variables
source $EVNDISPSYS/setObservatory.sh CTA

# output data files are written to this directory
mkdir -p "${ODIR}"
echo -e "Output files will be written to:\n ${ODIR}"

check_conda_installation()
{
    if command -v conda &> /dev/null; then
        echo "Found conda installation."
    else
        echo "Error: found no conda installation."
        echo "exiting..."
        exit
    fi
    env_info=$(conda info --envs)
    if [[ "$env_info" == *"$env_name"* ]]; then
        echo "Found conda environment '$env_name'"
    else
        echo "Error: the conda environment '$env_name' does not exist."
        echo "exiting..."
        exit
    fi
}

check_conda_installation

source activate base
conda activate $env_name

PREFIX="${ODIR}/dispdir_bdt"
LOGFILE="${PREFIX}.log"
rm -f "$LOGFILE"

if [[ $DSET == *"LaPalma"* ]]
    site="CTA-NORTH"
else
    site="CTA-SOUTH"
fi

eventdisplay-ml-train-xgb-stereo \
    --input_file_list "$LLIST" \
    --model_prefix "${PREFIX}" \
    --max_cores $MAXCORES \
    --observatory $site \
    --train_test_fraction $P --max_events $N >| "${LOGFILE}" 2>&1

python --version >> "${LOGFILE}"
conda list -n $env_name >> "${LOGFILE}"

conda deactivate
