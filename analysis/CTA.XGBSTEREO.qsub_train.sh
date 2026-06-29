#!/bin/bash
#
# train XGB stereo for CTA
#

ODIR=OUTPUTDIR
LLIST=MSCWLIST
MINTEL=TELMIN
DSET="DATASET"
env_name="eventdisplay_ml_cta"
P="0.90"
N="500000000"
MAXCORES=NCORE

# set environmental variables
source $EVNDISPSYS/setObservatory.sh CTA

# output data files are written to this directory
mkdir -p "${ODIR}"
echo -e "Output files will be written to:\n ${ODIR}"

check_conda_installation()
{
    if ! command -v conda &> /dev/null; then
        echo "Error: found no conda installation."
        echo "PATH: $PATH"
        exit 1
    fi

    if ! conda run -n "$env_name" --no-capture-output \
        bash -c 'command -v eventdisplay-ml-train-xgb-stereo' \
        > /dev/null; then
        echo "Error: the conda environment '$env_name' does not exist."
        echo "       or eventdisplay-ml-train-xgb-stereo is not installed in it."
        exit 1
    fi

    echo "Found conda environment '$env_name' with eventdisplay-ml installed."
}

check_conda_installation

PREFIX="${ODIR}/dispdir_bdt_mintel${MINTEL}"
LOGFILE="${PREFIX}.log"
rm -f "$LOGFILE"

if [[ $DSET == *"LaPalma"* ]]; then
    site="CTAO-NORTH"
else
    site="CTAO-SOUTH"
fi

{
    echo "Host: $(hostname)"
    echo "Conda: $(command -v conda)"
    conda run -n "$env_name" --no-capture-output \
        bash -c 'echo "Python: $(command -v python)"; echo "Trainer: $(command -v eventdisplay-ml-train-xgb-stereo)"'
} > "${LOGFILE}" 2>&1

conda run -n "$env_name" --no-capture-output \
    eventdisplay-ml-train-xgb-stereo \
    --input_file_list "$LLIST" \
    --model_prefix "${PREFIX}" \
    --max_cores $MAXCORES \
    --observatory $site \
    --max_tel_per_type 10 \
    --min_images $MINTEL --memory_profile \
    --train_test_fraction $P --max_events $N >> "${LOGFILE}" 2>&1
status=$?

conda run -n "$env_name" python --version >> "${LOGFILE}" 2>&1
conda list -n "$env_name" >> "${LOGFILE}" 2>&1

exit $status
