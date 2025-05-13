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
   for BDT in BDTDisp BDTDispEnergy BDTDispError BDTDispCore
   do
        for MCAZ in 0deg 180deg
        do
          FDIR=${DDIR}/${BDT}/${MCAZ}/
          if [[ ! -d ${DDIR} ]]; then
             echo "ERROR: directory with BDT disp data not found: ${DDIR}"
             echo "REDO ${A}"
             continue
          fi
          # number of result files
          NXML=$(ls -1 ${FDIR}/*.disptmva.root | wc -l)
          if [[ $NXML == "0" ]]; then
             echo "ERROR: no disp result files files found for ${BDT} at ${MCAZ}"
             echo "REDO ${A}"
          else
              echo "INFO: number of disp result files (=teltypes): $NXML (for ${BDT} at ${MCAZ})"
          fi
          # cross check that number of telescope types is the same for all BDT types/directories
          if [[ ${BDT} == "BDTDisp" ]] && [[ ${MCAZ} == "0deg" ]]; then
             NXMLF=${NXML}
          else
             if [[ ${NXML} != ${NXMLF} ]]; then
                echo "ERROR: different number of disp result files (${NXML} vs ${NXMLF}) for ${BDT} at ${MCAZ} (reference is BDTDisp,0deg)"
                echo "REDO ${A}"
             fi
          fi
          # test that disp result files are at least 1 MB large
          XMLF=$(ls -1 ${FDIR}/*.disptmva.root)
          for X in ${XMLF}
          do
             I=`wc -c ${X} | cut -d' ' -f1`
             if [[ ${I} -lt "100000" ]]; then
                echo "ERROR: disp result file too small: ${X} ({$I})"
                echo "REDO ${A}"
             fi
          done
        done
   done
done
