#!/bin/bash
#
# train XGB stereo for CTA
#

ODIR=OUTPUTDIR
LLIST=MSCWLIST
MINTEL=TELMIN
DSET="DATASET"
ENV_BIN="CONDA_ENV_BIN"
P="0.90"
N="500000000"
MAXCORES=NCORE

# set environmental variables
if [ -z "${EVNDISPSYS:-}" ] || [ ! -r "$EVNDISPSYS/setObservatory.sh" ]; then
    echo "Error: EVNDISPSYS is unset or setObservatory.sh is not readable." >&2
    exit 1
fi
source "$EVNDISPSYS/setObservatory.sh" CTA || exit 1

# ENV_BIN is resolved once by the submission script. Calling the executable
# directly avoids Conda startup and package-metadata access in every batch job.
XGB_TRAIN="${ENV_BIN}/eventdisplay-ml-train-xgb-stereo"
if [ ! -x "$XGB_TRAIN" ]; then
    echo "Error: incomplete eventdisplay-ml environment at '$ENV_BIN'." >&2
    exit 1
fi
export PATH="${ENV_BIN}:${PATH}"
export CONDA_PREFIX="${ENV_BIN%/bin}"

# output data files are written to this directory
mkdir -p "${ODIR}" || exit 1
echo -e "Output files will be written to:\n ${ODIR}"

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
    echo "Environment: $CONDA_PREFIX"
    echo "Trainer: $XGB_TRAIN"
} > "${LOGFILE}" 2>&1

"$XGB_TRAIN" \
    --input_file_list "$LLIST" \
    --model_prefix "${PREFIX}" \
    --max_cores $MAXCORES \
    --observatory $site \
    --max_tel_per_type 10 \
    --min_images $MINTEL --memory_profile \
    --train_test_fraction $P --max_events $N >> "${LOGFILE}" 2>&1
status=$?

exit "$status"
