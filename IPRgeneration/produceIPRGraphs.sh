#!/bin/sh
# Produce IPR graphs from NSB simulations
# Converts first simtel_array ouput file to DST
# and then produces the DST file
#
# Requires an Eventdisplay installation
# including all environmental variables
#

if [ $# -lt 1 ]; then
    echo "
    ./produceIPRGraphs.sh <(full) directory with simtel files> [production (default=PROD6; optional PROD5)
    "
    exit
fi
SCRATCH=$(realpath "$1")
[[ "$2" ]] && PROD=$2 || PROD="PROD6"
CDIR=$(pwd)

if [[ $PROD == "PROD5" ]]; then
    RUNPARA="EVNDISP.prod5.reconstruction.runparameter"
else
    RUNPARA="EVNDISP.prod6.reconstruction.runparameter"
fi
echo "Using ${RUNPARA} for Production ${PROD}"

FLIST=$(find $SCRATCH -name "*.simtel.gz")

for F in $FLIST
do
    FILEN=$(basename $F .simtel.gz)
    # make a temporary directory so that the dst file written will not be overwritten by a different process running
    mkdir -p ${SCRATCH}/temp_${FILEN}
    cd ${SCRATCH}/temp_${FILEN}
    # calculate pedestals
    echo "Calculate IPR graphs from ${SCRATCH}/${FILEN}.dst.root"
    $EVNDISPSYS/bin/evndisp -nevents=1000 \
                            -sourcefile ${SCRATCH}/${FILEN}.dst.root \
                            -runmode=1 -singlepedestalrootfile=1  \
                            -donotusepeds -usePedestalsInTimeSlices=0 \
                            -calibrationsumwindow=30 -calibrationsumfirst=0 \
                            -reconstructionparameter ${RUNPARA} \
                            -nopedestalsintimeslices  -combine_pedestal_channels ${ADC}

    mv -f dst.root ${SCRATCH}/${FILEN}.pedestal.root
    cd ${CDIR}
    rm -rf ${SCRATCH}/temp_${FILEN}
    echo "Pedestal file written to ${SCRATCH}/${FILEN}.pedestal.root"
done
