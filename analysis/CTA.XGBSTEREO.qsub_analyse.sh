#!/bin/bash
#
# train XGB stereo for CTA
#

MSCW_FILE="FFILE"
XGBDIR="DIRXGB"
MINTEL=TELMIN
XGB="xgb_stereo"
DSET="DATASET"
env_name="eventdisplay_ml_cta"
MAXCORES=1

# set environmental variables
source $EVNDISPSYS/setObservatory.sh CTA


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

# hardwired max training images to three
[ "$MINTEL" -ge 3 ] && MINTEL=3

PREFIX="${XGBDIR}/dispdir_bdt_mintel${MINTEL}"

if [[ $DSET == *"LaPalma"* ]]; then
    site="CTAO-NORTH"
else
    site="CTAO-SOUTH"
fi

OFIL=$(basename $MSCW_FILE .root)
ODIR=$(dirname $MSCW_FILE)
OFIL="${ODIR}/${OFIL}.${XGB}"
LOGFILE="${OFIL}.log"
rm -f "$LOGFILE"

echo "LOG FILE: $LOGFILE"

eventdisplay-ml-apply-xgb-stereo \
    --input_file "$MSCW_FILE" \
    --model_prefix "${PREFIX}" \
    --output_file "${OFIL}.root" \
    --max_cores $MAXCORES \
    --observatory $site  >| "${LOGFILE}" 2>&1

python --version >> "${LOGFILE}"
conda list -n $env_name >> "${LOGFILE}"

conda deactivate
