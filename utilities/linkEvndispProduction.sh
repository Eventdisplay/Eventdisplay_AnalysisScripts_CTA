#!/bin/bash
#
# link EVNDISP directories in analysis directories to
# general EVNDISP production 
# (assume that EVNDISP is stable in the development)
#
if [ ! -n "$3" ]
then
    echo "./linkEvndispProduction.sh <EVNDISP data set> <target data set> <list of layouts>"
    echo 
    exit
fi

# EVNDISP directory
HDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/$1"
if [[ ! -d ${HDIR} ]]; then
  echo "Error: directory with EVNDISP data set not found" 
  exit
fi
TDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${2}"
mkdir -p ${TDIR}

if [[ ! -e ${3} ]]; then
  echo "Error: array list not found ${3}"
  exit
fi

# list of arrays
ALIST=$(cat $3)

for A in $ALIST
do
   echo "Linking $A"

   mkdir -p ${TDIR}/${A}/EVNDISP
   rm -f ${TDIR}/${A}/EVNDISP/*

   for P in gamma_cone gamma_onSource proton electron
   do
      ln -s ${HDIR}/${A}/EVNDISP/${P} ${TDIR}/${A}/EVNDISP/${P}
   done
done
