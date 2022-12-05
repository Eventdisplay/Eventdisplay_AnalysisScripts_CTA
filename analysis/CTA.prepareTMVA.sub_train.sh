#!/bin/sh
#
# script to prepare event files for TMVA
#
#
#

SUBC="condor"
h_cpu="0:29:00"
h_vmem="4000M"
tmpdir_size="1G"

if [ $# -lt 4 ]
then
   echo
   echo "CTA.prepareTMVA.sub_train.sh <subarray list> <onSource/cone> <data set> <analysis parameter file> [qsub options] [direction (e.g. _180deg)] [job_dir]"
   echo ""
   echo "  <subarray list>   text file with list of subarray IDs"
   echo
   echo "  <onSource/cone>    calculate tables for on source or different wobble offsets"
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
echo "reading analysis parameter from $ANAPAR"
NIMAGESMIN=$(grep NIMAGESMIN "$ANAPAR" | awk {'print $2'})
NCUTLST=$(grep NLST "$ANAPAR" | awk {'print $2'})
NCUTMST=$(grep NMST "$ANAPAR" | awk {'print $2'})
NCUTSST=$(grep NSST "$ANAPAR" | awk {'print $2'})
NCUTMSCT=$(grep NSCMST "$ANAPAR" | awk {'print $2'})
ANADIR=$(grep MSCWSUBDIRECTORY  "$ANAPAR" | awk {'print $2'})
DDIR=$(grep TMVASUBDIR "$ANAPAR" | awk {'print $2'})
RECID=$(grep RECID "$ANAPAR" | awk {'print $2'})
echo "Analysis parameter: " "$NIMAGESMIN" "$ANADIR" "$DDIR"
DSET=$3
CONE="FALSE"
if [[ $2 == cone ]]
then
  CONE="TRUE"
fi
VARRAY=$(awk '{printf "%s ",$0} END {print ""}' "$1")

######################################################
# TMVA parameters are detetermined from data set name
RPAR="$CTA_EVNDISP_AUX_DIR/ParameterFiles/TMVA.BDT"
#####################################
if [ -n "$6" ]
then
  MCAZ=$6
fi

# batch farm submission options
if [ -n "$5" ]
then
   QSUBOPT="$5"
fi
QSUBOPT=${QSUBOPT//_X_/ } 
QSUBOPT=${QSUBOPT//_M_/-} 
QSUBOPT=${QSUBOPT//\"/} 

#####################################
# offset bins
if [ $CONE == "TRUE" ]
then
   OFFMIN=( 0.0 1.0 2.0 2.5 4.0 5.0 )
   OFFMAX=( 3.0 3.0 3.5 4.5 5.0 6.0 )
   OFFMEA=( 0.5 1.5 2.5 3.5 4.5 5.5 )
   DSUF="gamma_cone"
   GTYPE="cone10_evndisp"
   ASUF="gamma_onSource"
   ATYPE="baseline_evndisp"
else
   OFFMIN=( "0.0" )
   OFFMAX=( "3." )
# value used until 2015-11-09
#   OFFMAX=( "1.e10" )
   OFFMEA=( 0.0 )
   DSUF="gamma_onSource"
   GTYPE="baseline_evndisp"
   ASUF="gamma_cone"
   ATYPE="cone10_evndisp"
fi
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
DATE=$(date +"%y%m%d")
LDIR=$CTA_USER_LOG_DIR/$DATE/PRETMVATRAINING/
if [ -n ${7} ]; then
    LDIR=${7}
fi
QLOG=$LDIR
mkdir -p "$LDIR"
echo "Log directory: " "$LDIR"

######################################
# script name template
FSCRIPT="CTA.prepareTMVA.qsub_train"

###############################################################
# loop over all arrays
for ARRAY in $VARRAY
do
   echo "STARTING $DSET ARRAY $ARRAY MCAZ $MCAZ"

# signal and background files
# (no electrons are used for the background training)
# ensure mixed training set for the two different pointing directions
# two lists for signal and background, alternating from previous lists
# (list must be sorted; and then mixed)
# Splitmode=BLOCK
# SFIL1, BFIL1 used for training
# SFIL2, BFIL2 used for testing and analysis

# different namings for GRID and local productions
   if [[ ${DSET:0:2} == "GR" ]]
   then
       SFIL1=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/gamma*"deg$MCAZ"*"$GTYPE"*.mscw.root | sort -g | awk 'NR % 2 == 1')
       SFIL2=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/gamma*"deg$MCAZ"*"$GTYPE"*.mscw.root | sort -g | awk 'NR % 2 == 0')
       BFIL1=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/proton*"deg$MCAZ"*mscw.root | sort -g | awk 'NR % 2 == 1')
       BFIL2=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/proton*"deg$MCAZ"*mscw.root | sort -g | awk 'NR % 2 == 0')
       GFIL=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/gamma*"deg$MCAZ"*"$ATYPE"*.mscw.root)
       EFIL=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/elec*"deg$MCAZ"*mscw.root)
    elif [[ $DSET == *"NSB"* ]]
    then
       SFIL1=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/$DSUF*"_ID"$RECID"$MCAZ"*.mscw.root | sort -g | awk 'NR % 2 == 1')
       SFIL2=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/$DSUF*"_ID"$RECID"$MCAZ"*.mscw.root | sort -g | awk 'NR % 2 == 0')
       BFIL1=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/proton*"_ID"$RECID"$MCAZ"*mscw.root | sort -g | awk 'NR % 2 == 1')
       BFIL2=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/proton*"_ID"$RECID"$MCAZ"*mscw.root | sort -g | awk 'NR % 2 == 0')
       GFIL=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/$ASUF*"_ID"$RECID"$MCAZ"*.mscw.root)
       EFIL=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/elec*"_ID"$RECID"$MCAZ"*mscw.root)
    else
       SFIL1=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/$DSUF."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root | sort -g | awk 'NR % 2 == 1')
       SFIL2=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/$DSUF."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root | sort -g | awk 'NR % 2 == 0')
       BFIL1=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/proton."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root | sort -g | awk 'NR % 2 == 1')
       BFIL2=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/proton."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root | sort -g | awk 'NR % 2 == 0')
       GFIL=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/$ASUF."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root)
       EFIL=$(ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/electron."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root)
    fi

##########################################################
# set links for events used in effective area calculation
# (separate training and events used for analysis)
# NOTE: ASSUME THAT THIS IS NOT CHANGED
#       IF DIRECTORY EXISTS, NO NEW ONES ARE CREATED
    ANAEFF="$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/${ANADIR}.EFFAREA.MCAZ${MCAZ}"
    # rm -rf $ANAEFF
    if [ ! -e "$ANAEFF" ]
    then
        mkdir -p "$ANAEFF"
        # testing signal list
        for arg in $SFIL2
        do
            BW=$(basename "$arg")
            ln -s $arg "$ANAEFF"/"$BW"
        done
        # testing proton list
        for arg in $BFIL2
        do
            BW=$(basename "$arg")
            ln -s $arg "$ANAEFF"/"$BW"
        done
        # depending on CONE parameter: either onSource (if CONE=TRUE) or cone (if CONE=FALSE)
        for arg in $GFIL
        do
            BW=$(basename $arg)
            ln -s $arg $ANAEFF/$BW
        done
        # electrons (not used in training)
        for arg in $EFIL
        do
            BW=$(basename $arg)
            ln -s $arg $ANAEFF/$BW
        done
    else
        echo "EXISTING LINKED ANALYSIS (MSCW) FILES with testing events"
    fi
    ###############################################################
    # add a 'continue' here if linking file is the main purpose
    #continue
    ###############################################################

###############################################################
# get number of telescopes depending of telescope types

# use first file
   set -- $SFIL1
   # check the file exists - otherwise continue
   if [ -z "$1" ] || [ ! -e "$1" ]
   then
       echo "No training file found - continuing"
       echo $1
       exit
   fi
   echo "Teltype cuts: LSTs ($NCUTLST) MSTS ($NCUTMST) SSTs ($NCUTSST) MSCTs ($NCUTMSCT)"
   echo $1
   NTELTYPESTRING=$($EVNDISPSYS/bin/printRunParameter $1 -nteltypes)
   NTELTYPE=$(echo ${NTELTYPESTRING} | awk '{print $1}')
   NTYPECUT="NTtype==$NTELTYPE"
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
   TYPECUT="$NTYPECUT\&\&$TYPECUT"
   echo "Telescope type cut: $TYPECUT"

###############################################################
# Temporary run parameter file
   TEMPPAR=$LDIR/$FSCRIPT.$DSET.$ARRAY.AZ$MCAZ.$NIMAGESMIN.runpar
   rm -f ${TEMPPAR}
   touch "${TEMPPAR}"
   # write signal and background files
   # (note: training is in splitmode=block)
   for arg in $SFIL1
   do
      echo "* SIGNALFILE $arg" >> "${TEMPPAR}"
   done
   for arg in $BFIL1
   do
      echo "* BACKGROUNDFILE $arg" >> "${TEMPPAR}"
   done

   ODIR=$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/TMVA/
   mkdir -p "$ODIR"
###############################################################
# loop over all wobble offset
   for (( W = 0; W < $NOFF; W++ ))
   do
# prepare run parameter files
      RFIL="$ODIR/TMVA.BDT${MCAZ}-${RECID}-${OFFMEA[$W]}"
      echo $RFIL
      rm -f $RFIL.runparameter
echo "* ENERGYBINS 1 -5. 5.
* ZENITHBINS 0 90
* MCXYOFF (MCxoff*MCxoff+MCyoff*MCyoff)>=${OFFMIN[$W]}*${OFFMIN[$W]}&&(MCxoff*MCxoff+MCyoff*MCyoff)<${OFFMAX[$W]}*${OFFMAX[$W]}
* MCXYCUTSignalOnly 1
* OUTPUTFILE $ODIR MVA${MCAZ}-${RECID}-${OFFMEA[$W]}.training" > $RFIL.runparameter
      grep "*" $RPAR.runparameter | grep -v ENERGYBINS | grep -v OUTPUTFILE | grep -v SIGNALFILE | grep -v BACKGROUNDFILE | grep -v MCXYOFF | grep -v MINEVENTS >> $RFIL.runparameter
      echo "* MINEVENTS 0 0" >> $RFIL.runparameter
      cat "${TEMPPAR}" >> $RFIL.runparameter
############################################################
# setting the cuts in the run parameter file
      
      sed -i -e "s|MINIMAGES|$NIMAGESMIN|;s|MINIMAGETYPECUT|$TYPECUT|" \
             -e 's|ENERGYVARIABLE|ErecS|;s|ENERGYCHI2VARIABLE|EChi2S|g;s|ENERGYDEVARIABLE|dES|g' $RFIL.runparameter

      FNAM=$LDIR/$FSCRIPT.$DSET.$ARRAY.${OFFMEA[$W]}.AZ${MCAZ}.ID${RECID}.NIMAGES${NIMAGESMIN}
      sed -e "s|RUNPARA|$RFIL|" \
          -e "s|OOOFILE|$ODIR/MVA${MCAZ}-${RECID}-${OFFMEA[$W]}.training|" $FSCRIPT.sh > $FNAM.sh
      chmod u+x $FNAM.sh
      echo "SCRIPT $FNAM.sh"

# submit job to queue
      if [[ $SUBC == *qsub* ]]; then
          qsub $QSUBOPT -V -l h_cpu=${h_cpu} -l h_rss=${h_vmem} -l tmpdir_size=${tmpdir_size} -o $QLOG -e $QLOG "$FNAM.sh"
      elif [[ $SUBC == *condor* ]]; then
          ./condorSubmission.sh ${FNAM}.sh $h_vmem $tmpdir_size
      fi
    done
done
exit
