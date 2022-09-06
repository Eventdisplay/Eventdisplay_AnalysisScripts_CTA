#!/bin/sh
# Run analysis for all zenith angles and light levels
#

if [ $# -lt 1 ]; then
    echo "
    ./run_all.sh <producePedestals/produceIPRGraphs/mergeIPRGraphs>
    "
    exit
fi
RUNMODE=${1}

for Z in 20.0 40.0 60.0
do
    for M in dark full half
    do
        ZE=${Z%.*}
        if [[ $RUNMODE == "producePedestals" ]]; then
            ./producePedestals.sh PROD6 "${Z}" ${M}
        elif [[ $RUNMODE == "produceIPRGraphs" ]]; then
            ./produceIPRGraphs.sh PROD6/ze${ZE}deg-${M}
        elif [[ $RUNMODE == "mergeIPRGraphs" ]]; then
            ./mergeIPRGraphs.sh PROD6/ze${ZE}deg-${M} prod6-${M}-ze${ZE}deg-IPR.root
        else
            echo "Unknown run mode, should be one of producePedestals/produceIPRGraphs/mergeIPRGraphs"
        fi
    done
done
