#!/bin/bash
#
# count files in the different production directories
#
if [ ! -n "$3" ]
then
    echo "test-TMVA.sh <data set> <list of layouts> <recid>"
    echo 
    echo "   runmodes: EVNDISP"
    echo
    exit
fi

HDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/$1"
if [[ ! -d ${HDIR} ]]; then
  echo "Error: directory with data not found" 
  exit
fi

###########################################
# hardwired values
# wobble offsets
OFFMEA=( 0.5 1.5 2.5 3.5 4.5 5.5 )
NOFF=${#OFFMEA[@]}
# number of energy bins
NBINS="9"
# directory names
DIRN="ID${3}-NIM3LST3MST3SST3SCMST3-g20201021"
# (end of) hardwired values
###########################################

# big loops
ALIST=$(cat $2)
for A in $ALIST
do
  echo "Layout $A"
  HDIR=${CTA_USER_DATA_DIR}/analysis/AnalysisData/${1}/${A}/TMVA/

  for D in "_180deg" "_0deg"
  do
      # wobble bins
      for (( W = 0; W < $NOFF; W++ ))
      do
         # some XML files are always missing (e.g., below expected energy threshold)
         NMISS=()
         TDIR=${HDIR}/BDT-V3-${DIRN}-${OFFMEA[$W]}
         for (( E = 0; E < $NBINS; E++ ))
         do
             # check that BDT output file exists
             if [[ ! -e ${TDIR}/BDT_${E}.root ]] || [[ ! -s ${TDIR}/BDT_${E}.root ]]; then
                echo "MISSING BDT root file: ${TDIR}/BDT_${E}.root"
             fi
             # check that BDT XML file exists
             if [[ ! -e ${TDIR}/BDT_${E}_BDT_0.weights.xml ]] || [[ ! -s ${TDIR}/BDT_${E}_BDT_0.weights.xml ]]; then
                NMISS+=($E)
             fi
         done
         if [[ ${#NMISS[@]} > 0 ]]; then
             echo "List of missing XML files for ${A}, ${D}, ${OFFMEA[$W]} (this might be ok): ${NMISS[@]}"
         fi
      done
  done
done
