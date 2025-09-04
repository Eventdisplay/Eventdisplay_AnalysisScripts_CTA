#!/bin/bash
#
# script to train cuts/MVAs with TMVA
#
#
#

SUBC="condor"
h_cpu="11:29:00"
h_vmem="16000M"
tmpdir_size="1G"

if [ $# -lt 4 ]
then
   echo
   echo "CTA.TMVA.sub_train.sh <run mode > <subarray list> <data set> <analysis parameter file> [qsub options] [direction (e.g. _180deg)] [job_dir]"
   echo ""
   echo "  <run mode>        mva run mode ('TrainGammaHadronSeparation', 'TrainAngularReconstructionMethod', 'TrainReconstructionQuality')"
   echo
   echo "  <subarray list>   text file with list of subarray IDs"
   echo
   echo "  <data set>         e.g. cta-ultra3, ISDC3700, ...  "
   echo
   echo "  <direction>        e.g. for north: \"_180deg\", for south: \"_0deg\", for all directions: no option"
   echo
   echo "   note 1: keywords ENERGYBINS and OUTPUTFILE are ignored in the runparameter file"
   echo
   echo "   note 2: energy and wobble offset bins are hardwired in this scripts"
   echo
   echo "   note 3: adjust h_cpu depending on your MVA method"
   echo
   echo "   note 4: default TMVA parameter file is $CTA_EVNDISP_AUX_DIR/ParameterFiles/TMVA.BDT.runparameter"
   echo
   exit
fi

#######################################
# read values from parameter file
ANAPAR=$4
if [ ! -e "$ANAPAR" ]
then
  echo "error: analysis parameter file not found: $ANAPAR"
  exit
fi
TMVARUNMODE="$1"
echo "reading analysis parameter from $ANAPAR"
NIMAGESMIN=$(grep NIMAGESMIN "$ANAPAR" | awk {'print $2'})
NCUTLST=$(grep NLST "$ANAPAR" | awk {'print $2'})
NCUTMST=$(grep NMST "$ANAPAR" | awk {'print $2'})
NCUTSST=$(grep NSST "$ANAPAR" | awk {'print $2'})
NCUTMSCT=$(grep NSCMST "$ANAPAR" | awk {'print $2'})
ANADIR=$(grep MSCWSUBDIRECTORY  "$ANAPAR" | awk {'print $2'})
if [ $TMVARUNMODE == "TrainAngularReconstructionMethod" ]; then
    DDIR=$(grep TMVA_RECO_METHOD "$ANAPAR" | awk {'print $2'})
elif [ $TMVARUNMODE == "TrainReconstructionQuality" ]; then
    DDIR=$(grep TMVA_RECO_QUALITY "$ANAPAR" | awk {'print $2'})
else
    DDIR=$(grep TMVASUBDIR "$ANAPAR" | awk {'print $2'})
fi
RECID=$(grep RECID "$ANAPAR" | awk {'print $2'})
DSET=$3
echo "Analysis parameter: " "$NIMAGESMIN" "$ANADIR" "$DDIR"
OFIL="BDT"
VARRAY=$(awk '{printf "%s ",$0} END {print ""}' "$2")

######################################################
# TMVA parameters are detetermined from data set name
RPAR="$CTA_EVNDISP_AUX_DIR/ParameterFiles/TMVA.BDT"
RXPAR=$(basename "$RPAR".runparameter runparameter)
#####################################
MCAZ=${6:-$MCAZ}
# batch farm submission options
QSUBOPT=${5:-$QSUBOPT}
QSUBOPT=${QSUBOPT//_X_/ }
QSUBOPT=${QSUBOPT//_M_/-}
QSUBOPT=${QSUBOPT//\"/}
# log dir
DATE=$(date +"%y%m%d")
LDIR=$CTA_USER_LOG_DIR/$DATE/TRAIN/
LDIR=${7:-$LDIR}

#####################################
# energy bins
EMIN=( -1.90 -1.90 -1.45 -1.20 -0.95 -0.50 -0.10 0.45 0.90 )
EMAX=( -1.40 -1.30 -1.15 -0.80 -0.25  0.25 0.75 1.50 2.50 )
NENE=${#EMIN[@]}
#####################################
# offset bins
OFFMIN=( 0.0 1.0 2.0 2.5 4.0 5.0 )
OFFMAX=( 3.0 3.0 3.5 4.5 5.0 6.0 )
OFFMEA=( 0.5 1.5 2.5 3.5 4.5 5.5 )
NOFF=${#OFFMIN[@]}

######################################
# software paths
source ../setSoftwarePaths.sh "$DSET"
# checking the path for binary
if [ -z "$EVNDISPSYS" ]
then
    echo "no EVNDISPSYS env variable defined"
    exit
fi

######################################
# log files
QLOG=$LDIR
mkdir -p "$LDIR"
echo "Log directory: " "$LDIR"

######################################
# script name template
FSCRIPT="CTA.TMVA.qsub_train"

###############################################################
# loop over all arrays
for ARRAY in $VARRAY
do
   echo "STARTING $DSET ARRAY $ARRAY MCAZ $MCAZ"

###############################################################
# get number of telescopes depending of telescope types
# (expect that this is the same for all off-axis bins
   FFF=$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/TMVA/MVA${MCAZ}-${RECID}-${OFFMEA[0]}.training.root
   if [ ! -e "${FFF}" ]
   then
       echo "No training file found - continuing"
       echo ${FFF}
       exit
   fi
   echo "Teltype cuts: LSTs ($NCUTLST) MSTS ($NCUTMST) SSTs ($NCUTSST) MSCTs ($NCUTMSCT)"
   echo ${FFF}
   NTELTYPESTRING=$($EVNDISPSYS/bin/printRunParameter ${FFF} -nteltypes)
   NTELTYPE=$(echo ${NTELTYPESTRING} | awk '{print $1}')
   # find correct index for each cut
   for (( N = 0; N < $NTELTYPE; N++ ))
   do
       TELTYP=$(echo ${NTELTYPESTRING}| cut -d " " -f $((N+2)))
       if [[ $TELTYP == "NOTELESCOPETYPE" ]]; then
          echo "Error: telescope type not found: $N"
          echo "(check printRunParameters)"
          exit
       fi
       NCUT="NCUT${TELTYP}"
       if [ $N -eq 0 ]
       then
           TYPECUT="(NImages_Ttype[${N}]>=${!NCUT}"
       else
           TYPECUT="$TYPECUT\|\|NImages_Ttype[${N}]>=${!NCUT}"
       fi
   done
   if [ ! -z "$TYPECUT" ]
   then
       TYPECUT="${TYPECUT})"
   fi
   TYPECUT="$TYPECUT"
   echo "Telescope type cut: $TYPECUT"

###############################################################
# loop over all wobble offset
   for (( W = 0; W < $NOFF; W++ ))
   do
      ODIR=${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${ARRAY}/TMVA/${DDIR}-${OFFMEA[$W]}
      mkdir -p "$ODIR"
# copy run parameter file
      cp -f "$RPAR".runparameter "$ODIR"

# file with pre-selected training events
      PREEVENTLIST="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}/${ARRAY}/TMVA/MVA${MCAZ}-${RECID}-${OFFMEA[$W]}.training.root"

###############################################################
# loop over all energy bins and prepare run parameter files
      for ((i=0; i < $NENE; i++))
      do

# updating the  run parameter file
	 RFIL=$ODIR/$RXPAR$ARRAY"_$i"
	 echo $RFIL
	 rm -f $RFIL.runparameter
echo "* ENERGYBINS 1 ${EMIN[$i]} ${EMAX[$i]}
* ZENITHBINS 0 90
* MCXYOFF (MCxoff*MCxoff+MCyoff*MCyoff)>=${OFFMIN[$W]}*${OFFMIN[$W]}&&(MCxoff*MCxoff+MCyoff*MCyoff)<${OFFMAX[$W]}*${OFFMAX[$W]}
* MCXYCUTSignalOnly 1
* OUTPUTFILE $ODIR $OFIL"_$i" " > $RFIL.runparameter
	 grep "*" $RPAR.runparameter | grep -v ENERGYBINS | grep -v OUTPUTFILE | grep -v SIGNALFILE | grep -v BACKGROUNDFILE | grep -v MCXYOFF >> $RFIL.runparameter
         echo "* PREEVENTLIST ${PREEVENTLIST}" >> $RFIL.runparameter
############################################################
# setting the cuts in the run parameter file

         sed -i -e "s|MINIMAGES|$NIMAGESMIN|;s|MINIMAGETYPECUT|$TYPECUT|" \
                -e "s|TMVA_RUN_MODE|$TMVARUNMODE|" \
                -e 's|ENERGYVARIABLE|ErecS|;s|ENERGYCHI2VARIABLE|EChi2S|g;s|ENERGYDEVARIABLE|dES|g' $RFIL.runparameter
     done
     rm -f -v ${ODIR}/TMVA.BDT.runparameter

     FNAM=$LDIR/$FSCRIPT.$DSET.$ARRAY.${OFFMEA[$W]}.AZ${MCAZ}.ID${RECID}.NIMAGES${NIMAGESMIN}LST${NCUTLST}MST${NCUTMST}SST${NCUTSST}SCT${NCUTMSCT}
     RRFIL=$ODIR/$RXPAR$ARRAY
     sed -e "s|RUNPARA|$RRFIL|" \
         -e "s|NBINSNBINS|$NENE|" $FSCRIPT.sh > $FNAM.sh
     chmod u+x $FNAM.sh
     echo "SCRIPT $FNAM.sh"

     #################################
     # submit job to queue (for all energy bins)
     if [[ $SUBC == *qsub* ]]; then
         qsub $QSUBOPT -V -l h_cpu=${h_cpu} -l h_rss=${h_vmem} -l tmpdir_size=${tmpdir_size} -o $QLOG -e $QLOG "$FNAM.sh"
     elif [[ $SUBC == *condor* ]]; then
         ./condorSubmission.sh ${FNAM}.sh $h_vmem $tmpdir_size
     fi
  done
done
