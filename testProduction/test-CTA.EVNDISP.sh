#!/bin/bash
#
# test EVNDISP results
#
if [ ! -n "$2" ]
then
    echo "./test-CTA.EVNDISP.sh <data set> <list of layouts>"
    echo 
    echo
    exit
fi

HDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/$1"
if [[ ! -d ${HDIR} ]]; then
  echo "Error: directory with data not found" 
  exit
fi

ALIST=$(cat $2)

for A in $ALIST
do
   echo "Layout $A"

   for P in gamma_cone gamma_onSource proton electron
   do
      if [[ -d ${HDIR}/${A}/EVNDISP/${P} ]]; then
          SUF="EVNDISP"
      elif [[ ! -d ${HDIR}/${A}/${P} ]]; then
          echo "ERROR: EVNDISP direcotry not found: ${HDIR}/${A}/${P}"
      fi

      for D in "_180deg" "_0deg"
      do
          # check number of EVNDISP files
          TFIL=$(find ${HDIR}/${A}/${SUF}/${P}/ -name "*${D}*.root" | wc -l)
          echo "INFO: found for ${P}, ${D}: ${TFIL}"
      done
   done
done
