#!/bin/sh
# Produce IPR graphs from NSB simulations
#
# Requires an Eventdisplay installation
# including all environmental variables
#

SCRATCH='USER_SET_SIM_TELARRAY'

#####################################################################
# LST
#####################################################################

echo "Producing IPR graphs for LST"

sourceFile="${SCRATCH}/pedestals-lst-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels -ignoredstgains >& pedestals-lst.log;

mv -f dst.root pedestals-fadc-lst.root;


#####################################################################
# MST-NectarCam
#####################################################################

echo "Producing IPR graphs for MST-NectarCam"

sourceFile="${SCRATCH}/pedestals-mst-nc-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels -ignoredstgains >& pedestals-mst-nc.log;

mv -f dst.root pedestals-fadc-mst-nc.root;

#####################################################################
# MST-FlashCam
#####################################################################

echo "Producing IPR graphs for MST-FlashCam"

sourceFile="${SCRATCH}/pedestals-mst-fc-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels -ignoredstgains >& pedestals-mst-fc.log;

mv -f dst.root pedestals-fadc-mst-fc.root;

#####################################################################
# SST
#####################################################################

echo "Producing IPR graphs for SST"

sourceFile="${SCRATCH}/pedestals-sst-dst.root"

$EVNDISPSYS/bin/evndisp -nevents=1000 -sourcefile $sourceFile -runmode=1  -singlepedestalrootfile=1   -donotusepeds -usePedestalsInTimeSlices=0  -calibrationsumwindow=10 -calibrationsumfirst=0 -reconstructionparameter EVNDISP.prod5.reconstruction.runparameter -nopedestalsintimeslices  -combine_pedestal_channels -ignoredstgains >& pedestals-sst.log;

mv -f dst.root pedestals-fadc-sst.root;
