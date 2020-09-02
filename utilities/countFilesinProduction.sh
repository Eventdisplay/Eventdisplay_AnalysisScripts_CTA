#!/bin/bash
#
# count files in the different production directories
#
if [ ! -n "$3" ]
then
    echo "./countFilesinProduction.sh <data set> <list of layouts> <run mode>"
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

ALIST=$(cat $2)

for A in $ALIST
do
   echo "Layout $A"

   for P in gamma_cone gamma_onSource proton electron
   do
      echo "  ${P}"
      if [[ -d ${HDIR}/${A}/EVNDISP/${P} ]]; then
          SUF="EVNDISP"
      elif [[ ! -d ${HDIR}/${A}/${P} ]]; then
          continue
      fi

      for D in "_180deg" "_0deg"
      do
           echo "     ${D}"
           if [[ $3 == "EVNDISP" ]]; then
              NFIL=$(find ${HDIR}/${A}/${SUF}/${P} -name "*${D}*${A:2}*.root" | wc -l)
              TFIL=$(find ${HDIR}/${A}/${SUF}/${P} -name "*${D}*.root" | wc -l)
              echo "           ${NFIL}  (root files in dir: ${TFIL})"
           fi
      done
   done
done
