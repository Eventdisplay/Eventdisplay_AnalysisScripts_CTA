#!/bin/bash
#
# script to prepare training events
#
#
#

PFIL=RUNPARA
OFIL=OOOFILE
ulimit -n 2056

# set the right observatory (environmental variables)
source "${EVNDISPSYS}"/setObservatory.sh CTA

echo ${PFIL}.runparameter
rm -f $PFIL.log

${EVNDISPSYS}/bin/trainTMVAforGammaHadronSeparation "${PFIL}".runparameter WRITETRAININGEVENTS > "${PFIL}".log

# mv log file into root file
if [ -e ${PFIL}.log ] && [ -e ${OFIL}.root ]
then
    ${EVNDISPSYS}/bin/logFile tmvaPrepareLog ${OFIL}.root ${PFIL}.log
#    rm -f ${PFIL}.log
fi
if [ -e ${PFIL}.runparameter ]
then
    ${EVNDISPSYS}/bin/logFile tmvaPrepareRunparameter ${OFIL}.root ${PFIL}.runparameter
#    rm -f ${PFIL}.runparameter
fi

exit
