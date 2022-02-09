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
./produceIPRGraphs.sh <directory with simtel files>
    "
    exit
fi
SCRATCH=${1}
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
    # calculate pedestals
    echo "Calculate IPR graphs"
    $EVNDISPSYS/bin/evndisp -nevents=1000 \
                            -sourcefile ${SCRATCH}/${FILEN}.dst.root \
                            -runmode=1 -singlepedestalrootfile=1  \
                            -donotusepeds -usePedestalsInTimeSlices=0 \
                            -calibrationsumwindow=10 -calibrationsumfirst=0 \
                            -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter \
                            -nopedestalsintimeslices  -combine_pedestal_channels ${ADC} \
                            >& ${SCRATCH}/${FILEN}.pedestal.log

    mv -f dst.root ${SCRATCH}/${FILEN}.pedestal.root
    echo "Pedestal file written to ${SCRATCH}/${FILEN}.pedestal.root"
done
