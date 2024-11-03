#!/bin/bash
#
# link EVNDISP directories in analysis directories to
# production directory
#
if [ ! -n "$2" ]
then
    echo "./linkEvndispProductionToProductionDirectory.sh <directory with file lists> <target data set>"
    echo
    exit
fi

# File lists
HDIR="$1"
if [[ ! -d ${HDIR} ]]; then
  echo "Error: directory with file lists set not found"
  exit
fi
TDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${2}"
mkdir -p ${TDIR}

if [[ $(basename $HDIR) == *"LaPalma"* ]]; then
    A="N.hyperarray"
else
    A="S.hyperarray"
fi


mkdir -p ${TDIR}/${A}/EVNDISP

for P in gamma_cone gamma_onSource proton electron
do
  rm -f ${TDIR}/${A}/EVNDISP/${P}/*
  mkdir -p ${TDIR}/${A}/EVNDISP/${P}
  echo "${TDIR}/${A}/EVNDISP/${P}"
  FLIST=${HDIR}/${P}.list
  FILES=$(cat $FLIST)
  for F in $FILES; do
      ln -s $F ${TDIR}/${A}/EVNDISP/${P}/$(basename $F)
  done
done
