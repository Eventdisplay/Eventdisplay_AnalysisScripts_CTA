#!/bin/bash
#
# Separate training files for DispBDT traing
#
# - fraction of gamma_cone and gamma_onSource
# - random selection of files
# - removes links to S.hyperarray / N.hyperarray for files used for training
# - links to files in "<array_name>/EVNDISP.DISPTRAINING/..."


if [ ! -n "$2" ]
then
    echo "./separateDispTrainingEvndispFiles.sh <data set> <list of layouts>"
    echo
    echo "Used for gamma_onSource and gamma_cone only"
    echo "(hardwired fraction of files)"
    exit
fi

# Fractions used for train
declare -A LOOKUP=(
  [gamma_cone]=5       # 20%
  [gamma_onSource]=10  # 10%
  [proton]=1000        # 1% (not used)
  [electron]=1000      # 1% (not used)
)

# data set
HDIR="${CTA_USER_DATA_DIR%/}/analysis/AnalysisData/$1"
if [[ ! -d ${HDIR} ]]; then
  echo "Error: dataset directory not found"
  exit
fi
HYPERARRAY="N.hyperarray"
if [[ $1 == *Paranal* ]]; then
    HYPERARRAY="S.hyperarray"
fi

if [[ ! -e ${2} ]]; then
  echo "Error: layout list not found ${3}"
  exit
fi


# Fill list with all EVNDISP files (randomized)
echo "Filling file lists from Hyperarray"
for MCAZ in 0deg 180deg
do
   for P in gamma_cone gamma_onSource proton electron
   do
     ALL_FILE_LIST=${HDIR}/${HYPERARRAY}/EVNDISP/${P}_${MCAZ}.all.list
     rm -f ${ALL_FILE_LIST}
     find $HDIR/${HYPERARRAY}/EVNDISP/${P}/ -name "*[_,.]${MCAZ}*.root" | shuf > ${ALL_FILE_LIST}
     echo "   Found $(wc -l ${ALL_FILE_LIST}) files for ${P} ${MCAZ}"
   done
done

# list of arrays
ALIST=$(cat $2)
for ARRAY in $ALIST
do
   echo "Working on layout $ARRAY into ${HDIR}/${ARRAY}"

   # Analysis files
   ANADIR="${HDIR}/${ARRAY}/EVNDISP.ANALYSIS"
   mkdir -p ${ANADIR}
   rm -rf ${ANADIR}/*
   # Training files
   TRAINDIR="${HDIR}/${ARRAY}/EVNDISP.TRAIN"
   mkdir -p ${TRAINDIR}
   rm -rf ${TRAINDIR}/*

   for MCAZ in 0deg 180deg
   do
       for P in gamma_cone gamma_onSource proton electron
       do
           echo "   Filling ${P} for ${MCAZ} with fraction of ${LOOKUP[$P]}"

           ALL_FILE_LIST=${HDIR}/${HYPERARRAY}/EVNDISP/${P}_${MCAZ}.all.list
           TRAIN_FILE_LIST=${TRAINDIR}/${P}_${MCAZ}.all.list
           ANA_FILE_LIST=${ANADIR}/${P}_${MCAZ}.all.list

           awk -v n="${LOOKUP[$P]}" 'NR % n == 0' "$ALL_FILE_LIST" > "$TRAIN_FILE_LIST"
           awk -v n="${LOOKUP[$P]}" 'NR % n != 0' "$ALL_FILE_LIST" > "$ANA_FILE_LIST"
           echo "      Training files: $(wc -l ${TRAIN_FILE_LIST})"
           echo "      Analysis files: $(wc -l ${ANA_FILE_LIST})"
     done

   done
done
