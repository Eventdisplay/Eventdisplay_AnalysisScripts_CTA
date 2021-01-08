#!/bin/sh
# Produce IPR graphs from NSB simulations
#
# Requires an Eventdisplay installation
# including all environmental variables
#
# Change the two variables at the top:
#  SCRATCH: scratch space to save the output
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time

SCRATCH="USER_SET_SCRATCH"

ZE="20"
# ZE="60"

MOONOPT="" # Set to -DHALFMOON for half moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

ADC="" # Set to -ignoredstgains if you want to produce graphs in ADC counts rather than p.e.

#####################################################################
# LST
#####################################################################

echo "Producing IPR graphs for LST"

sourceFile="${SCRATCH}/pedestals-lst${MOON}-ze-${ZE}-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels ${ADC} >& pedestals-lst${MOON}-ze-${ZE}.log;

mv -f dst.root pedestals-lst${MOON}-ze-${ZE}.root;


#####################################################################
# MST-NectarCam
#####################################################################

echo "Producing IPR graphs for MST-NectarCam"

sourceFile="${SCRATCH}/pedestals-mst-nc${MOON}-ze-${ZE}-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels ${ADC} >& pedestals-mst-nc${MOON}-ze-${ZE}.log;

mv -f dst.root pedestals-mst-nc${MOON}-ze-${ZE}.root;

#####################################################################
# MST-FlashCam
#####################################################################

echo "Producing IPR graphs for MST-FlashCam"

sourceFile="${SCRATCH}/pedestals-mst-fc${MOON}-ze-${ZE}-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels ${ADC} >& pedestals-mst-fc${MOON}-ze-${ZE}.log;

mv -f dst.root pedestals-mst-fc${MOON}-ze-${ZE}.root;

#####################################################################
# SST
#####################################################################

echo "Producing IPR graphs for SST"

sourceFile="${SCRATCH}/pedestals-sst${MOON}-ze-${ZE}-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels ${ADC} >& pedestals-sst${MOON}-ze-${ZE}.log;

mv -f dst.root pedestals-sst${MOON}-ze-${ZE}.root;
