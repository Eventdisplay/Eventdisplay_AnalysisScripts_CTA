#!/bin/sh
#
# Run all prod6 scripts over all zenith angles and NSB levels
#

if [ $# -lt 1 ]; then
    echo "
    ./CTA.runAllScripts.sh <run mode>

    run modes:
        MAKETABLES DISPBDT ANATABLES PREPARETMVA TRAIN ANGRES QC CUTS PHYS CLEANUP
        MAKETABLES PREPAREFILELISTS DISPBDT ANATABLES XGBSTEREOTRAIN XGBSTEREOANA PREPARETMVA TRAIN PREPAREANA ANGRES QC CUTS PHYS CLEANUP

    optional run modes: TRAIN_RECO_QUALITY TRAIN_RECO_METHOD

    "
    exit
fi
# run mode
RUN="$1"

for ZE in 20deg 40deg 52deg 60deg; do
    for NSB in dark moon; do
        dataset="prod6-North-${ZE}-${NSB}"
        ./CTA.mainRunScriptsReduced.sh $dataset $RUN
    done
done
