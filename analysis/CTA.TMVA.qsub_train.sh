#!/bin/bash
#
# script to train cuts/MVAs with TMVA
#
#
#

RPARA=RUNPARA
NENE=NBINSNBINS

ulimit -n 2056

# set the right observatory (environmental variables)
source "${EVNDISPSYS}"/setObservatory.sh CTA

for ((EBIN=0; EBIN < $NENE; EBIN++))
do
    PFIL=${RPARA}_${EBIN}
    rm -f $PFIL.log

    echo ${PFIL}.runparameter

    ${EVNDISPSYS}/bin/trainTMVAforGammaHadronSeparation "${PFIL}".runparameter >> "${PFIL}".log

    CDIR=$(dirname "$PFIL".log)
    # remove .C files (never used; we use the XML files)
    rm -f "$CDIR"/BDT_"${EBIN}"*.C
    # remove complete_BDTroot at the end of the run
    # (generally not used, but takes up lots of disk space)
    # rm -rf $CDIR/complete_BDTroot/BDT_${EBIN}*
    rm -rf "$CDIR"/complete_BDTroot

    # mv log file into root file
    if [ -e ${PFIL}.log ] && [ -e $CDIR/BDT_${EBIN}.root ]
    then
        ${EVNDISPSYS}/bin/logFile tmvaLog $CDIR/BDT_${EBIN}.root ${PFIL}.log
        rm -f ${PFIL}.log
    fi
    if [ -e ${PFIL}.runparameter ] && [ -e $CDIR/BDT_${EBIN}.root ]
    then
        ${EVNDISPSYS}/bin/logFile tmvaRunparameter $CDIR/BDT_${EBIN}.root ${PFIL}.runparameter
        rm -f ${PFIL}.runparameter
    fi
    # mv xml file into root file
    if [ -e $CDIR/BDT_${EBIN}_BDT_0.weights.xml ] && [ -e $CDIR/BDT_${EBIN}.root ]
    then
       ${EVNDISPSYS}/bin/logFile tmvaXML $CDIR/BDT_${EBIN}.root $CDIR/BDT_${EBIN}_BDT_0.weights.xml
       rm -f $CDIR/BDT_${EBIN}_BDT_0.weights.xml
    fi
done

exit
