#!/bin/bash
#
# script to prepare list of MC files from a local directory
#
#

if [[ $# < 2 ]]; then
# begin help message
echo "
Prepare list of MC files from a local directory

./prepareSimulationFileLists.sh <directory with MC files> <directory to write file lists>

expect subdirectories for particle types
"
exit
fi

MCDIR=${1}
ODIR=${2}

# output directory
mkdir -p ${2}


for P in gamma_cone gamma_onSource proton electron
do
   if [[ -e ${ODIR}/${P}.list ]]; then
      echo "Output file list ${ODIR}/${P}.list; please remove"
      exit
   fi

   echo "Filling list for ${P}:"
   echo "   from: ${MCDIR}/${P}/"
   echo "   into: ${ODIR}/${P}.list"

   find "${MCDIR}/${P}/" -name "*simtel.lin.root" > ${ODIR}/${P}.list
#   find "${MCDIR}/${P}/" -name "*simtel.sq2.root" > ${ODIR}/${P}.list

   echo "total number of files found: "
   wc -l ${ODIR}/${P}.list
done
