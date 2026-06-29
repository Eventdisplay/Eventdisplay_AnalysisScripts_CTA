#!/bin/bash
#
# train XGB stereo for CTA
#

MSCW_FILE="FFILE"
XGBDIR="DIRXGB"
MINTEL=TELMIN
XGB="xgb_stereo"
DSET="DATASET"
ENV_BIN="CONDA_ENV_BIN"
MAXCORES=1

# set environmental variables
if [ -z "${EVNDISPSYS:-}" ] || [ ! -r "$EVNDISPSYS/setObservatory.sh" ]; then
    echo "Error: EVNDISPSYS is unset or setObservatory.sh is not readable." >&2
    exit 1
fi
source "$EVNDISPSYS/setObservatory.sh" CTA || exit 1

# ENV_BIN is resolved once by the submission script.  Calling the executable
# directly avoids conda startup and package-metadata access in every batch job.
XGB_APPLY="${ENV_BIN}/eventdisplay-ml-apply-xgb-stereo"
if [ ! -x "$XGB_APPLY" ]; then
    echo "Error: incomplete eventdisplay-ml environment at '$ENV_BIN'." >&2
    exit 1
fi
export PATH="${ENV_BIN}:${PATH}"
export CONDA_PREFIX="${ENV_BIN%/bin}"

# hardwired max training images to three
[ "$MINTEL" -ge 3 ] && MINTEL=3

PREFIX="${XGBDIR}/dispdir_bdt_mintel${MINTEL}"
MODEL_OPTIONS=( --model_prefix "${PREFIX}" )
# For NIM2 output, use different models for 2 and
# high multiplicity events
OMINTEL=${MINTEL}
[ "$OMINTEL" -eq 2 ] && OMINTEL=23
if [ "$MINTEL" -eq 2 ]; then
    MODEL_OPTIONS+=(
        --model_prefix_high_multiplicity
        "${XGBDIR}/dispdir_bdt_mintel3"
    )
    OMINTEL=23
fi

if [[ $DSET == *"LaPalma"* ]]; then
    site="CTAO-NORTH"
else
    site="CTAO-SOUTH"
fi

OFIL=$(basename $MSCW_FILE .root)
ODIR=$(dirname $MSCW_FILE)
OFIL="${ODIR}/${OFIL}.${XGB}_mintel${OMINTEL}"
LOGFILE="${OFIL}.log"
rm -f "$LOGFILE"

echo "LOG FILE: $LOGFILE"

"$XGB_APPLY" \
    --input_file "$MSCW_FILE" \
    "${MODEL_OPTIONS[@]}" \
    --output_file "${OFIL}.root" \
    --max_cores $MAXCORES \
    --observatory $site  >| "${LOGFILE}" 2>&1
status=$?

exit "$status"
