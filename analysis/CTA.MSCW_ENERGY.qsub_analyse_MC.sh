#!/bin/bash
#
# script to analyse CTA MC files with lookup tables
#
#

TABFIL=TABLEFILE
RECID=RECONSTRUCTIONID
IFIL="IIIIFIL"
TFIL=TTTTFIL
ARRAY=ARRAYYY
DSET=DATASET
ADIR=AAAAADIR
MCAZ=AZIMUTH

# set the right observatory (environmental variables)
source $EVNDISPSYS/setObservatory.sh CTA

# output data and log files are written to this directory
ODIR=$CTA_USER_DATA_DIR"/analysis/AnalysisData/"$DSET"/"$ARRAY"/$ADIR/"
mkdir -p $ODIR

# delete old log files
rm -f $ODIR/$TFIL.log
rm -f $ODIR/$TFIL.table.log

# table directory
TABDIR=$CTA_USER_DATA_DIR"/analysis/AnalysisData/"$DSET"/"$ARRAY"/Tables/"

#########################################
# smooth / cp table file to temp disk
SMOOTH="TRUE"
if [ $SMOOTH == "TRUE" ]
then
    $EVNDISPSYS/bin/smoothLookupTables $TABDIR/$TABFIL-$ARRAY.root $TMPDIR/$TABFIL-$ARRAY.root > $ODIR/$TFIL.table.log
else
    cp -v $CTA_EVNDISP_AUX_DIR/Tables/$TABFIL-$ARRAY.root $TMPDIR/$TABFIL-$ARRAY.root > $ODIR/$TFIL.table.log
fi

#########################################
# cp all evndisp root files to TMPDIR
echo "Coppying evndisp root files to TMPDIR"
echo "number of files: "
wc -l $IFIL

NFIL=`cat $IFIL`
DDIR=$TMPDIR/data
mkdir -p $DDIR
for F in $NFIL
do
   cp $F $DDIR/
done
find $DDIR/ -name "*.root" > $TMPDIR/iList.list
# ls -1 $DDIR/*.root > $TMPDIR/iList.list

# check disk space on TMPDIR
du -h -c $TMPDIR

###############################################
# mscw_energy command line options
###############################################
MOPT="-pe -arrayrecid=$RECID -noNoTrigger -writeReconstructedEventsOnly -shorttree -useMedian=2 -add_mc_spectral_index=2.5"

# strip array scaling (two characters) for paranal sites
DARR=${ARRAY}
if  [[ $DSET == *"prod4"* ]]
then
    LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod4${DARR}.lis
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
else
     echo "error: unknown data set $DSET"
     exit
fi


#########################################
# options for simple stereo reconstruction
MOPT="$MOPT -redo_stereo_reconstruction -sub_array_sim_telarray_counting $LISFILE -minangle_stereo_reconstruction=15"

# IMPORTANT: this must be the same or lower value as in dispBDT training
MOPT="$MOPT -maxloss=0.2 -minfui=0."

#########################################
# disp main directory name
DISPSUBDIR="BDTdisp.${ARRAY}.T1085"

#########################################
# options for DISP method (direction)
DISPDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/"$DSET"/${DISPSUBDIR}/BDTDisp/${MCAZ}/BDTDisp_BDT_"
MOPT="$MOPT -tmva_nimages_max_stereo_reconstruction=100 -tmva_filename_stereo_reconstruction $DISPDIR"

##########################################################################################################
# options for DISP method (direction error)
DISPERRORDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/"$DSET"/${DISPSUBDIR}/BDTDispError/${MCAZ}/BDTDispError_BDT_"
MOPT="$MOPT  -tmva_filename_disperror_reconstruction $DISPERRORDIR -tmva_disperror_weight 50"

##########################################################################################################
# options for DISP method (core)
DISPCOREDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/"$DSET"/${DISPSUBDIR}/BDTDispCore/${MCAZ}/BDTDispCore_BDT_"
MOPT="$MOPT -tmva_filename_core_reconstruction $DISPCOREDIR"

##########################################################################################################
# options for DISP method (energy)
DISPENERGYDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/"$DSET"/${DISPSUBDIR}/BDTDispEnergy/${MCAZ}/BDTDispEnergy_BDT_"
MOPT="$MOPT -tmva_filename_energy_reconstruction $DISPENERGYDIR"

################################
# telescope type dependent weight
# prod3b production
if [[ $DSET == *"prod3b"* ]]
then
       MOPT="$MOPT -teltypeweightfile $CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3b.TelescopeWeights.dat"
fi
echo $MOPT

#########################################
# analyse MC file
$EVNDISPSYS/bin/mscw_energy $MOPT -tablefile $TMPDIR/$TABFIL-$ARRAY.root -inputfilelist $TMPDIR/iList.list -outputfile $TMPDIR/$TFIL.root >& $ODIR/$TFIL.log
#########################################

#########################################
# clean up and mv loog file into root file
if [ -e $ODIR/$TFIL.table.log ] && [ -e $TMPDIR/$TFIL.root ]
then
     $EVNDISPSYS/bin/logFile smoothTableLog $TMPDIR/$TFIL.root $ODIR/$TFIL.table.log
     rm -f $ODIR/$TFIL.table.log
fi
if [ -e $ODIR/$TFIL.log ] && [ -e $TMPDIR/$TFIL.root ]
then
     $EVNDISPSYS/bin/logFile mscwTableLog $TMPDIR/$TFIL.root $ODIR/$TFIL.log
     rm -f $ODIR/$TFIL.log
fi
if [ -e $TMPDIR/iList.list ] && [ -e $TMPDIR/$TFIL.root ]
then
     $EVNDISPSYS/bin/logFile mscwTableList $TMPDIR/$TFIL.root $TMPDIR/iList.list
     rm -f $TMPDIR/iList.list
     rm -f $IFIL
fi
   
mv -f -v $TMPDIR/$TFIL.root $ODIR/

# sleep
sleep 2

exit
