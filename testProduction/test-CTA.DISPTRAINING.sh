#!/bin/sh
#
# test TMVA BDTs for DISP


# disp training types
if [ $# -lt 2 ]
then
echo "
./test-CTA.DISPTRAINING.sh <data set> <list of layouts>

test results of disp BDT training

"
exit
fi

# BDT suffix
BDTS=".T1"

# directory with disp results
HDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${1}/DISPBDT/"
if [[ ! -d ${HDIR} ]]; then
  echo "ERROR: directory with data not found: ${HDIR}" 
  exit
fi

# list of arrays
ALIST=$(cat $2)
for A in ${ALIST}
do
   echo "Layout $A"
   DDIR=${HDIR}/BDTdisp.${A}${BDTS}
   if [[ ! -d ${DDIR} ]]; then 
      echo "ERROR: directory with disp data not found: ${DDIR}" 
      continue
   fi
   for BDT in BDTDisp BDTDispEnergy BDTDispError BDTDispCore BDTDispPhi
   do
        for MCAZ in 0deg 180deg
        do
          FDIR=${DDIR}/${BDT}/${MCAZ}/
          if [[ ! -d ${DDIR} ]]; then
             echo "ERROR: directory with BDT disp data not found: ${DDIR}"
             echo "REDO ${A}"
             continue
          fi
          # number of XML files
          NXML=$(ls -1 ${FDIR}/*.xml | wc -l)
          if [[ $NXML == "0" ]]; then
             echo "ERROR: no XML files found for ${BDT} at ${MCAZ}"
             echo "REDO ${A}"
          else
              echo "INFO: number of XML files (=teltypes): $NXML (for ${BDT} at ${MCAZ})"
          fi
          # cross check that number of telescope types is the same for all BDT types/directories
          if [[ ${BDT} == "BDTDisp" ]] && [[ ${MCAZ} == "0deg" ]]; then
             NXMLF=${NXML}
          else
             if [[ ${NXML} != ${NXMLF} ]]; then
                echo "ERROR: different number of XML files (${NXML} vs ${NXMLF}) for ${BDT} at ${MCAZ} (reference is BDTDisp,0deg)"
                echo "REDO ${A}"
             fi
          fi
          # test that XML files are note of zero length
          XMLF=$(ls -1 ${FDIR}/*.xml)
          for X in ${XMLF}
          do
             if [[ ! -s ${X} ]]; then
                echo "ERROR: XML file of zero length: ${X}"
                echo "REDO ${A}"
             fi
          done
        done
   done
done
