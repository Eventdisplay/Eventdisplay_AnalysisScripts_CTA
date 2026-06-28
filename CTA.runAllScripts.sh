#!/bin/sh
#
# Run all prod6 scripts over all zenith angles and NSB levels
#

if [ $# -lt 1 ]; then
    echo "
    ./CTA.runAllScripts.sh <run mode>

    run modes:
        MAKETABLES PREPAREFILELISTS DISPBDT ANATABLES XGBSTEREOTRAIN XGBSTEREOANA PREPARETMVA TRAIN PREPAREANA ANGRES QC CUTS PHYS CLEANUP

    optional run modes: TRAIN_RECO_QUALITY TRAIN_RECO_METHOD

    "
    exit
fi
# run mode
RUN="$1"
SITE="South"

for ZE in 20deg;
    for NSB in dark; do
        dataset="prod6-${SITE}-${ZE}-${NSB}"
        ./CTA.mainRunScriptsReduced.sh $dataset $RUN
    done
done
