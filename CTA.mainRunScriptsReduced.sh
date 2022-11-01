#!/bin/sh
#
# wrapper analysis script to run
# different multiplicity cut dependent
# steps
#

if [ $# -lt 2 ]; then
    echo "
./CTA.mainRunScripts.sh <data set> <run mode>
    
    data sets:
        prod5-South-20deg prod5-South-40deg prod5-South-60deg
        prod5-South-20deg-moon prod5-South-40deg-moon prod5-South-60deg-moon
        prod5b-North-20deg prod5b-North-40deg prod5b-North-60deg
        prod5b-North-20deg-moon prod5b-North-40deg-moon prod5b-North-60deg-moon
        prod3b-S20deg-SCTAlpha

    run modes:
        MAKETABLES DISPBDT ANATABLES PREPARETMVA TRAIN ANGRES QC CUTS PHYS

    "
    exit
fi
# site
P2="$1"
# run mode
RUN="$2"
# loop over LSTs
[[ "$3" ]] && LST=$3 || LST="FALSE"

NMULT=( 2 3 4 5 6 )
if [[ ${P2} == *"North"* ]]; then
   NMULT=( 2 3 4 )
fi
LSTMULT=( 2 3 4 )

# run scripts are collected here
RUNSCRIPTDIR="${CTA_USER_LOG_DIR}/jobs/$(uuidgen)"
mkdir -p ${RUNSCRIPTDIR}
    
if [[ ${RUN} == "MAKETABLES" ]] || [[ ${RUN} == "DISPBDT" ]] || [[ ${RUN} == "ANATABLES" ]] || [[ ${RUN} == "PREPARETMVA" ]]; then
   ./CTA.runAnalysis.sh ${P2} ${RUN}
   ./CTA.runAnalysis.sh ${P2}-sub ${RUN}
else
    while IFS= read -r mult
    do
        ./CTA.runAnalysis.sh ${P2} ${RUN} 0 $mult ${RUNSCRIPTDIR}
    done < NIM-South-test.txt
    # tmp
    exit
    # tmp(end)
    while IFS= read -r mult
    do
        ./CTA.runAnalysis.sh ${P2}-sub ${RUN} 0 $mult
    done < NIM-South-sub.txt
fi
