#!/bin/bash
#
# prepare a hyper production
#
if [ ! -n "$3" ]
then
    echo "./setSoftwarePaths.sh <hyper data set> <target data set> <list of layouts>"
    echo 
    echo "   Note: Hyperarray fixed for North Layout"
    echo
    exit
fi
HARRAY="N.MSTN.hyperarray"

HDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/$1"
if [[ ! -d ${HDIR} ]]; then
  echo "Error: directory with hyper data set not set" 
  exit
fi
TDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${2}"
mkdir -p ${TDIR}

if [[ ! -e ${3} ]]; then
  echo "Error: array list not found ${3}"
  exit
fi

ALIST=$(cat $3)

for A in $ALIST
do
   echo "Linking $A"

   mkdir -p ${TDIR}/${A}/EVNDISP
   rm -rfv ${TDIR}/${A}/EVNDISP/*

   for P in gamma_cone gamma_onSource proton electron
   do
      ln -s ${HDIR}/${HARRAY}/EVNDISP/${P} ${TDIR}/${A}/EVNDISP/${P}
   done
done
