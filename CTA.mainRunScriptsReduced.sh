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

       Prod3b analysis:
            prod3b-S20deg-SCTAlpha
       Prod5 analysis:
            prod5-South-20deg prod5-South-40deg prod5-South-60deg
            prod5-South-20deg-moon prod5-South-40deg-moon prod5-South-60deg-moon
            prod5b-North-20deg prod5b-North-40deg prod5b-North-60deg
            prod5b-North-20deg-moon prod5b-North-40deg-moon prod5b-North-60deg-moon
       Prod6 analysis:
            prod6-North-20deg prod6-North-40deg prod6-North-52deg
            prod6-South-20deg

    run modes:
        MAKETABLES DISPBDT ANATABLES PREPARETMVA TRAIN ANGRES QC CUTS PHYS

    "
    exit
fi
# site
P2="$1"
# run mode
RUN="$2"

SITE="South"
if [[ $P2 == *"North"* ]]; then
    SITE="North"
fi

RECID="0"

# run scripts are collected here
RUNSCRIPTDIR="${CTA_USER_LOG_DIR}/jobs/$(uuidgen)"
mkdir -p ${RUNSCRIPTDIR}

if [[ ${RUN} == "MAKETABLES" ]] || [[ ${RUN} == "DISPBDT" ]] || [[ ${RUN} == "ANATABLES" ]] || [[ ${RUN} == "PREPARETMVA" ]]; then
   ./CTA.runAnalysis.sh ${P2} ${RUN} ${RECID} 2 2 2 2 ${RUNSCRIPTDIR}
   if [[ $SITE == "South" ]] || [[ $P2 == *"prod6"* ]]; then
       ./CTA.runAnalysis.sh ${P2}-sub ${RUN} ${RECID} 2 2 2 2 ${RUNSCRIPTDIR}
   elif [[ $SITE == *"North"* ]]; then
       ./CTA.runAnalysis.sh ${P2}-LST ${RUN} ${RECID} 2 2 2 2 ${RUNSCRIPTDIR}
   fi
else
   while IFS= read -r mult
   do
       ./CTA.runAnalysis.sh ${P2} ${RUN} ${RECID} $mult ${RUNSCRIPTDIR}
   done < NIM-${SITE}.dat
   if [[ $SITE == "South" ]]; then
       while IFS= read -r mult
       do
           ./CTA.runAnalysis.sh ${P2}-sub ${RUN} ${RECID} $mult ${RUNSCRIPTDIR}
       done < NIM-${SITE}-sub.dat
   elif [[ $SITE == "North" ]]; then
       ./CTA.runAnalysis.sh ${P2}-LST ${RUN} ${RECID} 2 2 2 2 ${RUNSCRIPTDIR}
   fi
fi

echo "#####"
echo "RUNSCRIPTDIR: ${RUNSCRIPTDIR}/${RUN}"
