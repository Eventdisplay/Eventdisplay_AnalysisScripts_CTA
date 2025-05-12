#!/bin/sh
# Converts first simtel_array ouput file to DST for IPR generation
#
# Requires an Eventdisplay installation
# including all environmental variables
#

if [ $# -lt 1 ]; then
    echo "
./convertToDST.sh <directory with simtel files> [production (default=PROD6; optional PROD5)
    "
    exit
fi
SCRATCH=${1}
[[ "$2" ]] && PROD=$2 || PROD="PROD6"
CDIR=$(pwd)

FLIST=$(find $SCRATCH -name "*.simtel.gz")

for F in $FLIST
do
    FILEN=$(basename $F .simtel.gz)
    echo "Converting $F to DST"

    # convert to DST
    $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis \
                                               -f 2 \
                                               -o ${SCRATCH}/${FILEN}.dst.root \
                                               $F \
                                               >& ${SCRATCH}/${FILEN}.dst.log

    echo "DST file written to ${SCRATCH}/${FILEN}.dst.root"
done
