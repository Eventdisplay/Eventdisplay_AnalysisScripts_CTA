#!/bin/sh
#
# wrapper analysis script to run
# different multiplicity cut dependent
# steps
#

if [ $# -lt 2 ]; then
    echo "
./CTA.mainRunScripts.hs <data set> <run mode>
    
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
    
if [[ ${RUN} == "MAKETABLES" ]] || [[ ${RUN} == "DISPBDT" ]] || [[ ${RUN} == "ANATABLES" ]] || [[ ${RUN} == "PREPARETMVA" ]]; then
   ./CTA.runAnalysis.sh ${P2} ${RUN}
   ./CTA.runAnalysis.sh ${P2}-sub ${RUN}
else
    if [[ ${P2} == *"South"* ]] || [[ ${P2} == *"SCTAlpha"* ]]; then
        # no LST loop
        if [[ $LST == "FALSE" ]]; then
            for M in "${NMULT[@]}"
            do
               for S in "${NMULT[@]}"
               do
                 # minimum between MSTs and SSTs
                 NIM=$(($M<$S ? $M : $S))
                ./CTA.runAnalysis.sh ${P2} ${RUN} 0 $NIM $M $S $NIM
                 if [[ "$S" == "$M" ]]; then
                  ./CTA.runAnalysis.sh ${P2}-sub ${RUN} 0 $NIM $M $S $NIM
                 fi
               done
            done
        # with LST loop
        else
            echo "LST loop $LST"
            for M in "${NMULT[@]}"
            do
               for S in "${NMULT[@]}"
               do
                 for L in "${LSTMULT[@]}"
                 do
                     # minimum between MSTs and SSTs
                     NIM=$(($M<$S ? $M : $S))
                     echo "LST $L  MST $M  SST $S  SCT $NIM"
                    ./CTA.runAnalysis.sh ${P2} ${RUN} 0 $L $M $S $NIM
                     if [[ "$S" == "$M" ]]; then
                        ./CTA.runAnalysis.sh ${P2}-sub ${RUN} 0 $L $M $S $NIM
                     fi
                 done
               done
            done     
       fi
    else
        for M in "${NMULT[@]}"
        do
            for L in "${LSTMULT[@]}"
            do
                 ./CTA.runAnalysis.sh ${P2} ${RUN} 0 $L $M $M $M
            done
            ./CTA.runAnalysis.sh ${P2}-sub ${RUN} 0 $M $M $M $M
        done
    fi
fi

