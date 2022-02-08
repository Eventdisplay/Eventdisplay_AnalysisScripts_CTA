#!/bin/sh
# Produce DST files from NSB simulations
#
# Requires an Eventdisplay installation
# including all environmental variables
#
# Change the two variables at the top:
#  SCRATCH: scratch space to save the output
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time

SCRATCH="USER_SET_SCRATCH"
CDIR=$(pwd)

ZE="20"
# ZE="60"

MOONOPT="" # Set to -DHALFMOON for half moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

#####################################################################
# LST
#####################################################################

sourceFile="${SCRATCH}/pedestals-lst${MOON}-ze-${ZE}-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-lst${MOON}-ze-${ZE}-dst.root $sourceFile >& lst${MOON}-ze-${ZE}-dst.log &


#####################################################################
# MST-NectarCam
#####################################################################

sourceFile="${SCRATCH}/pedestals-mst-nc${MOON}-ze-${ZE}-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-mst-nc${MOON}-ze-${ZE}-dst.root $sourceFile >& mst-nc${MOON}-ze-${ZE}-dst.log &


#####################################################################
# MST-FlashCam
#####################################################################

sourceFile="${SCRATCH}/pedestals-mst-fc${MOON}-ze-${ZE}-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-mst-fc${MOON}-ze-${ZE}-dst.root $sourceFile >& mst-fc${MOON}-ze-${ZE}-dst.log &

#####################################################################
# SST
#####################################################################

sourceFile="${SCRATCH}/pedestals-sst${MOON}-ze-${ZE}-1k.simtel.gz"

$EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${CDIR}/geometry-1-telescope.lis -f 2 -o ${SCRATCH}/pedestals-sst${MOON}-ze-${ZE}-dst.root $sourceFile >& sst${MOON}-ze-${ZE}-dst.log &
