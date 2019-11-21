#!/bin/bash
#
# script to train cuts/MVAs with TMVA
#
#
#

RPARA=RUNPARA
EBIN=EEEE

ulimit -n 2056

# set the right observatory (environmental variables)
source $EVNDISPSYS/setObservatory.sh CTA

PFILE=${RPARA}_${EBIN}
rm -f $PFIL.log

$EVNDISPSYS/bin/trainTMVAforGammaHadronSeparation $PFILE.runparameter > $PFILE.log

CDIR=`dirname $PFILE`
# remove .C files (never used; we use the XML files)
rm -f $CDIR/BDT_${EBIN}*.C
# remove complete_BDTroot at the end of the run
# (generally not used, but takes up lots of disk space)
# rm -rf $CDIR/complete_BDTroot/BDT_${EBIN}*
rm -rf $CDIR/complete_BDTroot

# mv log file into root file
if [ -e $PFILE.log ] && [ -e $CDIR/BDT_${EBIN}.root ]
then
    $EVNDISPSYS/bin/logFile tmvaLog $CDIR/BDT_${EBIN}.root $PFILE.log
    rm -f $PFILE.log
fi
if [ -e $PFILE.runparameter ] && [ -e $CDIR/BDT_${EBIN}.root ]
then
    $EVNDISPSYS/bin/logFile tmvaRunparameter $CDIR/BDT_${EBIN}.root $PFILE.runparameter
    rm -f $PFILE.runparameter
fi

exit
