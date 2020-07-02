#!/bin/sh
# Produce DST files from NSB simulations
#
# Requires an Eventdisplay installation
# including all environmental variables
#

SCRATCH='USER_SET_SCRATCH'
CDIR=$(pwd)

#####################################################################
# LST
#####################################################################

sourceFile="${SCRATCH}/pedestals-lst-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-lst-dst.root $sourceFile >& log-lst-dst.txt &


#####################################################################
# MST-NectarCam
#####################################################################

sourceFile="${SCRATCH}/pedestals-mst-nc-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-mst-nc-dst.root $sourceFile >& log-mst-nc-dst.txt &


#####################################################################
# MST-FlashCam
#####################################################################

sourceFile="${SCRATCH}/pedestals-mst-fc-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-mst-fc-dst.root $sourceFile >& log-nst-fc-dst.txt &

#####################################################################
# SST
#####################################################################

sourceFile="${SCRATCH}/pedestals-sst-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-sst-dst.root $sourceFile >& log-sst-dst.txt &
