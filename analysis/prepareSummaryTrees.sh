#!/bin/sh
# Prepare summary IRF trees from WP Phys results
#
# expect following (standard) environmental variables
# $EVNDISPSYS
# $DATADIR
#

# dataset used for layout optimisation
DDAT="g20210409-20deg"
#DDAT="g20210409-40deg"
#DDAT="g20210409-60deg"
PDAT="g20210921"
FLIST="./prod5/subArray.prod5.South-sub.list"
if [[ ! -e ${FLIST} ]]; then
   echo "telescope list not found: $FLIST"
   exit
fi
# (end of hardwired values)

echo "$DATADIR"
DSET=$(basename $DATADIR)
echo "Preparing summary IRF trees for $DSET"

#for S in 15MSTs50SSTs SubArray
#for S in 13MSTs30SSTs 13MSTs40SSTs 14MSTs40SSTs 15MSTs50SSTs 12MSTs40SSTs 10MSTs40SSTs
for S in SubArray
do
   for A in Average 180deg 0deg
   do
        OFILE=Phys-${DDAT}-${A}Az-NIMOPT-${S}
        PHYSDIR="$DATADIR/Phys-${DDAT}/"
        PHYSDIR="$DATADIR/archive.202105/Phys-${DDAT}-${S}/"
        if [[ ! -d ${PHYSDIR} ]]; then
           echo "phys dir not found: ${PHYSDIR}"
           exit
        fi
        echo "   reading IRF files from ${PHYSDIR}"
        rm -f ${OFILE}.log
        ${EVNDISPSYS}/bin/writeCTAWPPhysSensitivityTree ${FLIST} ${DSET} ${OFILE}.root ${A} 0 ${PHYSDIR} ${PDAT} > ${OFILE}.log
   done
done
