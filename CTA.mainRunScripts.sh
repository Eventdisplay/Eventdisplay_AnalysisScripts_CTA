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
        prod5-South prod5-South-40deg prod5-South-60deg
        prod5-North prod5-North-40deg prod5-North-60deg

    run modes:
        MAKETABLES DISPBDT ANATABLES PREPARETMVA TRAIN ANGRES QC CUTS PHYS

    "
    exit
fi
# site
P2="$1"
# run mode
RUN="$2"
    
if [[ ${RUN} == "MAKETABLES" ]] || [[ ${RUN} == "DISPBDT" ]] || [[ ${RUN} == "ANATABLES" ]] || [[ ${RUN} == "PREPARETMVA" ]]; then
   ./CTA.runAnalysis.sh ${P2} ${RUN}
   ./CTA.runAnalysis.sh ${P2}-sub ${RUN}
else
    for M in 2 3 4 5 6
    do
       for S in 2 3 4 5 6
       do
         # minimum between MSTs and SSTs
         NIM=$(($M<$S ? $M : $S))
        ./CTA.runAnalysis.sh ${P2} ${RUN} 0 $NIM $M $S $NIM
         if [[ "$S" == "$M" ]]; then
              ./CTA.runAnalysis.sh ${P2}-sub ${RUN} 0 $NIM $M $S $NIM
         fi
       done
    done
fi


