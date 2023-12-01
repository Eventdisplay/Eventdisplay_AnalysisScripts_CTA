#!/bin/sh
# 
# convert Eventdisplay event lists to FITS
#

if [ $# -lt 2 ]; then
   echo "
./convert_to_DL2.sh <directory with effective area files> <list of arrays>
   "
   exit
fi

# check if converter script exists
if [[ ! -e ${EVNDISPSYS}/../Converters/DL2/generate_DL2_file.py ]]; then
   echo "Converter script not found" 
   echo "   expected in ${EVNDISPSYS}/../Converters/DL2/generate_DL2_file.py"
   exit
fi

# list of arrays
ARRAYS=$(cat $3)

for A in $ARRAYS
do
    # list of effective area files
    FLIST=$(find ${1} -path "*BDT*" -name "*${A}*.root")

    # Loop over all cut levels and convert the files
    for C in 0 1 2 
    do
       for F in $FLIST
       do
          if [[ ! -e ${F} ]]; then
             echo "Error: file not found: $F"
             continue;
          fi

          OFIL=$(basename $F .root)
          OFIL=${OFIL}-CUT${C}.fits.gz

          OPTIONS="-c ${C} -o ${1}/${OFIL} -l ${A}"
          echo "CONVERTING ${F}"
          python ${EVNDISPSYS}/../Converters/DL2/generate_DL2_file.py ${OPTIONS} ${F}
          echo "---------------"
       done
    done
done
