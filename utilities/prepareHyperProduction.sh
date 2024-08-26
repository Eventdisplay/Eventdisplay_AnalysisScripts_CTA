#!/bin/bash
#
# prepare a hyper production directory with links to files in the remove data directory
#
if [ ! -n "$2" ]
then
    echo "./setSoftwarePaths.sh <directory with file lists> <hyper array directory>"
    echo
    exit
fi

# directory with file lists
LDIR="${1}"

TDIR="${2}"
mkdir -p ${TDIR}


for P in gamma_onSource gamma_cone proton electron; do
   echo "Linking $P from $FLIST"

   FLIST="${LDIR}/${P}.list"
   if [[ ! -e ${FLIST} ]]; then
       echo "Error: file list ${FLIST} not found"
       continue
   fi
   FILES=$(cat $FLIST)

   CURR_DIR=$(pwd)
   mkdir -p ${TDIR}/${P}
   cd ${TDIR}/${P}

   for FILE in $FILES; do
       ln -s "${FILE}" .
   done
   cd "${CURR_DIR}"

done
