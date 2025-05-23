#!/bin/bash
#
# fill tables for CTA
#
#

TFIL=TABLEFILE
RECID=RECONSTRUCTIONID
ARRAY=ARRRRRRR
CONE="CCC"
DSET="DATASET"
MCAZ="AZIMUTH"
MINTEL="MMTEL"

# set the right observatory (environmental variables)
source ${EVNDISPSYS}/setObservatory.sh CTA

# output data files are written to this directory
ODIR=${CTA_USER_DATA_DIR}"/analysis/AnalysisData/$DSET/"$ARRAY"/Tables/"
mkdir -p $ODIR

# output log files are written to this directory
LDIR=${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/"$ARRAY"/Tables/
mkdir -p $LDIR

# rename on-axis tables
if [ $CONE == "FALSE" ]
then
   TFIL=${TFIL}-onAxis
fi

# delete old log files
rm -f $LDIR/$TFIL-$ARRAY.log
# delete old table file (mscw_energy would otherwise stop with an error message)
rm -f $LDIR/$TFIL-$ARRAY.root

MCAZ=${MCAZ/_/}

################################
# generate input file lists
TMPLIST=$LDIR/${DSET}${MCAZ}.${ARRAY}.list
rm -f $TMPLIST
touch $TMPLIST
if [ $CONE == "TRUE" ]
then
   find ${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/$ARRAY/EVNDISP/gamma_cone/ -name "*[0-9]*[\.,_]${MCAZ}*.root" >> $TMPLIST
   echo "${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/$ARRAY/EVNDISP/gamma_cone/ -name \"*[0-9]*[\.,_]${MCAZ}*.root\""
# on-axis gamma rays
else
   find ${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/$ARRAY/EVNDISP/gamma_onSource/ -name "*[0-9]*[\.,_]${MCAZ}*.root" >> $TMPLIST
   echo "${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/$ARRAY/EVNDISP/gamma_onSource/ -name \"*[0-9]*[\.,_]${MCAZ}*.root\""
fi

################################
# options for table filling
if [ $CONE == "TRUE" ]
then
   SETOFF="-CTAoffAxisBins"
fi

# strip array scaling (two characters) for paranal sites
DARR=${ARRAY}
if  [[ $DSET == *"prod4"* ]]
then
    LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod4${DARR}.lis
elif [[ $DSET == *"prod5"* ]]
then
    LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${DARR}.lis
elif [[ $DSET == *"prod6"* ]]
then
    LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod6${DARR}.lis
elif [[ $DSET == *"prod3"* ]]
then
    if [[ $DSET == *"paranal"* ]] && [[ $DSET != *"prod3b"* ]]
    then
       DARR=${ARRAY%??}
       LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3${DARR}.lis
    elif [[ $DSET == *"LaPalma"* ]] || [[ $DARR == "Sb"* ]]
    then
       DARR=${ARRAY}
       LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3${DARR}.lis
    else
       LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3Sb${DARR:1}.lis
    fi
fi

MOPT="$SETOFF -pe -filltables=1 -ze=20. -noise=250 -woff=0.0 -minImages=${MINTEL} -write1DHistograms"
# options for reweighting of telescopes
MOPT="$MOPT -redo_stereo_reconstruction -sub_array_sim_telarray_counting $LISFILE -minangle_stereo_reconstruction=10"
MOPT="$MOPT -maxnevents=3000000"
# options for single telescope analysis
if [ ${MINTEL} -eq 1 ]
then
   MOPT="$MOPT -use_mc_parameters"
fi

################################
# telescope type dependent weight
# prod3b production
if [[ $DSET == *"prod3b"* ]] && [[ $DSET != *"SCT"* ]]
then
       MOPT="$MOPT -teltypeweightfile $CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3b.TelescopeWeights.dat"
fi
echo $MOPT

#########################################
# fill tables
${EVNDISPSYS}/bin/mscw_energy $MOPT -arrayrecid=$RECID -tablefile "$ODIR/$TFIL-$ARRAY.root" -inputfilelist ${TMPLIST} > $LDIR/$TFIL-$ARRAY.log
#########################################

# move log files into root file
if [ -e $LDIR/$TFIL-$ARRAY.log ]
then
     ${EVNDISPSYS}/bin/logFile makeTableLog $ODIR/$TFIL-$ARRAY.root $LDIR/$TFIL-$ARRAY.log
     rm -f $LDIR/$TFIL-$ARRAY.log
fi
if [ -e ${TMPLIST} ]
then
     ${EVNDISPSYS}/bin/logFile makeTableFileList $ODIR/$TFIL-$ARRAY.root ${TMPLIST}
     rm -f ${TMPLIST}
fi

# sleep
sleep 2

exit
