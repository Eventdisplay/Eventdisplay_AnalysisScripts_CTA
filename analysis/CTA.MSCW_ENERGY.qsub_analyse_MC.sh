#!/bin/bash
#
# script to analyse CTA MC files with lookup tables
#

TABFIL=TABLEFILE
RECID=RECONSTRUCTIONID
TFIL=TTTTFIL
ARRAY=ARRAYYY
DSET=DATASET
ADIR=AAAAADIR
MCAZ=AZIMUTH
FILEN=FILELENGTH
TFILE=FILELIST
MINIMAGE=NNNIMAGE
PID="PIDNOTSET"

# gridengine compatibility
re='^[0-9]+$'
if ! [[ $PID =~ $re ]] ; then
    PID=$SGE_TASK_ID
fi

# counter
l=$((PID * FILEN))
l=$((l - FILEN))
l=$((l + 1))
let "k = $l + $FILEN - 1"
echo "COUNTER $PID $l $k"

# set the right observatory (environmental variables)
source $EVNDISPSYS/setObservatory.sh CTA

# output MSCWFILE
TFIL=${TFIL}-$l.mscw

# output data and log files are written to this directory
ODIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${ARRAY}/${ADIR}/"
mkdir -p $ODIR

# FILE LIST
IFIL=${TMPDIR}/${TFIL}.list
echo $TFILE
echo $IFIL
sed -n "$l,$k p" $TFILE > $IFIL
wc -l $IFIL

# delete old log files
rm -f $ODIR/$TFIL.log
rm -f $ODIR/$TFIL.table.log

# table directory
TABDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${ARRAY}/Tables/"

#########################################
# smooth / cp table file to temp disk
SMOOTH="TRUE"
if [ $SMOOTH == "TRUE" ]
then
    $EVNDISPSYS/bin/smoothLookupTables $TABDIR/$TABFIL-$ARRAY.root $TMPDIR/$TABFIL-$ARRAY.root > $ODIR/$TFIL.table.log
else
    cp -v $TABDIR/$TABFIL-$ARRAY.root $TMPDIR/$TABFIL-$ARRAY.root > $ODIR/$TFIL.table.log
fi

#########################################
# cp all evndisp root files to TMPDIR
echo "Copying evndisp root files to TMPDIR"
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
####
## temporary - check all files for consistency
#LL=$(cat $TMPDIR/iList.list)
#rm -f ${ODIR}/${TFIL}.testOutput.log
#touch ${ODIR}/${TFIL}.testOutput.log
#for L in ${LL}
#do
#    $EVNDISPSYS/bin/testEvndispOutput ${L} prod5-South >> ${ODIR}/${TFIL}.testOutput.log
#done

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
elif [[ $DSET == *"prod6"* ]]
then
    LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod6${DARR}.lis
elif [[ $DSET == *"prod5"* ]]
then
    LISFILE=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${DARR}.lis
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
MOPT="$MOPT -redo_stereo_reconstruction -sub_array_sim_telarray_counting $LISFILE"
if [[ $DSET == *"LaPalma"* ]]; then
    MOPT="$MOPT -minangle_stereo_reconstruction=15."
else
    MOPT="$MOPT -minangle_stereo_reconstruction=10."
fi
# IMPORTANT: this must be the same or lower value as in dispBDT training
if [[ $RECID == "1" ]]; then
    MOPT="$MOPT -maxloss=0.1 -minfui=0."
    MOPT="$MOPT -maxdistfraction=0.70"
elif [[ $RECID == "2" ]]; then
    MOPT="$MOPT -maxloss=0.2 -minfui=0."
    MOPT="$MOPT -maxdistfraction=0.75"
else
    MOPT="$MOPT -maxloss=0.2 -minfui=0."
    MOPT="$MOPT -maxdistfraction=0.80"
fi

#########################################
# disp reconstruction
#
MVATYPE="BDT"
# disp main directory name
DISPSUBDIR="DISPBDT/${MVATYPE}disp.${ARRAY}.R1"
echo "CHECKING ${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${DISPSUBDIR/${ARRAY}/HYPERARRAY}"
if [[ -d ${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${DISPSUBDIR/${ARRAY}/HYPERARRAY} ]]; then
    DISPSUBDIR="${DISPSUBDIR/${ARRAY}/HYPERARRAY}"
    echo "Choosing hyperarray DispDir"
else
    echo "Did not find hyperarray DispDir ${DISPSUBDIR/${ARRAY}/HYPERARRAY}"
fi
echo "DISPDIR $DISPSUBDIR"
#########################################
# unpack disp XML files for all telescope
# types to tmpdir (not all of them might be used)
for ML in ${MVATYPE}Disp ${MVATYPE}DispError ${MVATYPE}DispEnergy ${MVATYPE}DispCore
do
   MLDDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${DISPSUBDIR}/${ML}/${MCAZ}/"
   echo "Unpacking ${ML} from ${MLDDIR}"
   FF=$(find ${MLDDIR} -name "$ML*disptmva.root")
   for F in ${FF}
   do
      TTYPE=$(basename ${F} .disptmva.root | cut -d'-' -f 2)
      MLFIL="${MLDDIR}/${ML}-${TTYPE}.disptmva.root"
      if [[ -e ${MLFIL} ]]; then
           MLODIR="${TMPDIR}/${ML}/${MCAZ}/"
           mkdir -p ${MLODIR}
           $EVNDISPSYS/bin/logFile dispXML-${MVATYPE}-${TTYPE} ${MLFIL} > ${MLODIR}/${ML}_${MVATYPE}_${TTYPE}.weights.xml
           echo "dispXML dispXML-${MVATYPE}-${TTYPE} ${MLFIL}"
           ls -l ${MLODIR}
#           if grep -q NOXML ${MLODIR}/${ML}_${MVATYPE}_${TTYPE}.weights.xml
#           then
#             echo "Error reading dispBDT xml files: dispXML-${MVATYPE}-${TTYPE} ${MLFIL}"
#             exit
#           fi
      fi
   done
done

#########################################
# options for DISP method (direction)
DISPDIR="${TMPDIR}/${MVATYPE}Disp/${MCAZ}/${MVATYPE}Disp_${MVATYPE}_"
MOPT="$MOPT -tmva_nimages_max_stereo_reconstruction=100 -tmva_filename_stereo_reconstruction $DISPDIR"

##########################################################################################################
# options for DISP method (direction error)
DISPERRORDIR="${TMPDIR}/${MVATYPE}DispError/${MCAZ}/${MVATYPE}DispError_${MVATYPE}_"
MOPT="$MOPT -tmva_filename_disperror_reconstruction $DISPERRORDIR -tmva_disperror_weight 50"

##########################################################################################################
# options for DISP method (core)
# (switch on for single-telescope analysis)
DISPCOREDIR="${TMPDIR}/${MVATYPE}DispCore/${MCAZ}/${MVATYPE}DispCore_${MVATYPE}_"
if [[ $ARRAY == *"1LSTs"* ]] || [[ $ARRAY == *"01MSTs"* ]]; then
     MOPT="$MOPT -tmva_filename_core_reconstruction $DISPCOREDIR"
fi
# single telescope multiplicity (note expectation on array naming)
if [[ $ARRAY == *"1LSTs00MSTs"* ]] || [[ $ARRAY == *"0LSTs01MSTs"* ]]; then
    MINIMAGE=1
fi

##########################################################################################################
# options for DISP method (energy)
DISPENERGYDIR="${TMPDIR}/${MVATYPE}DispEnergy/${MCAZ}/${MVATYPE}DispEnergy_${MVATYPE}_"
MOPT="$MOPT -tmva_filename_energy_reconstruction $DISPENERGYDIR"

################################
# allow single image events
MOPT="$MOPT -minImages=${MINIMAGE}"

################################
# telescope type dependent weight
# prod3b production
if [[ $DSET == *"prod3b"* ]] && [[ $DSET != *"SCT"* ]]
then
       MOPT="$MOPT -teltypeweightfile $CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3b.TelescopeWeights.dat"
elif [[ $DSET == *"prod5"* ]]
then
       MOPT="$MOPT -teltypeweightfile $CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5.TelescopeWeights.dat"
elif [[ $DSET == *"prod6"* ]]
then
       MOPT="$MOPT -teltypeweightfile $CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod6.TelescopeWeights.dat"
fi
echo $MOPT

#########################################
# analyse MC file
$EVNDISPSYS/bin/mscw_energy $MOPT -tablefile $TMPDIR/$TABFIL-$ARRAY.root \
                                  -inputfilelist $TMPDIR/iList.list \
                                  -outputfile $TMPDIR/$TFIL.root >& $ODIR/$TFIL.log
#                                  -pixellist \
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
