#!/bin/bash
#
# script to train cuts/MVAs with TMVA
#
#
#

RPARA=RUNPARA
let "EBIN = $SGE_TASK_ID - 1"

ulimit -n 2056

# set the right observatory (environmental variables)
source "${EVNDISPSYS}"/setObservatory.sh CTA

PFIL=${RPARA}_${EBIN}
rm -f $PFIL.log

# this file is deleted after successful 
# completion of training
touch ${PFIL}.${SGE_JOB_ID}.${SGE_TASK_ID}.RUNNING

echo ${PFIL}.runparameter

${EVNDISPSYS}/bin/trainTMVAforGammaHadronSeparation "${PFIL}".runparameter > "${PFIL}".log

CDIR=$(dirname "$PFIL".log)
# remove .C files (never used; we use the XML files)
rm -f "$CDIR"/BDT_"${EBIN}"*.C
# remove complete_BDTroot at the end of the run
# (generally not used, but takes up lots of disk space)
# rm -rf $CDIR/complete_BDTroot/BDT_${EBIN}*
rm -rf "$CDIR"/complete_BDTroot

# check successful completion of training
# remove temporary file
if [ -e ${PFIL}.log ]; then
   TSTRING=$(tail -n 1 ${PFIL}.log | grep Complete)
   echo "$TSTRING"
   if [ ! -z "$TSTRING" ]; then
      rm -f ${PFIL}.${SGE_JOB_ID}.${SGE_TASK_ID}.RUNNING
   fi
   TSTRING=$(tail -n 3 ${PFIL}.log | grep "not enough")
   if [ ! -z "$TSTRING" ]; then
      rm -f ${PFIL}.${SGE_JOB_ID}.${SGE_TASK_ID}.RUNNING
   fi
fi

# mv log file into root file
if [ -e ${PFIL}.log ]
then
    ${EVNDISPSYS}/bin/logFile tmvaLog $CDIR/BDT_${EBIN}.root ${PFIL}.log
    rm -f ${PFIL}.log
fi
if [ -e ${PFIL}.runparameter ] && [ -e $CDIR/BDT_${EBIN}.root ]
then
    ${EVNDISPSYS}/bin/logFile tmvaRunparameter $CDIR/BDT_${EBIN}.root ${PFIL}.runparameter
    rm -f ${PFIL}.runparameter
fi

exit
