#!/bin/bash
#
# XGB stereo analysis training
#
#
#

SUBC="condor"
h_cpu="8:29:00"
h_vmem="24000M"
tmpdir_size="1G"

if [ $# -lt 4 ]
then
   echo
   echo "/CTA.XGBSTEREOTRAINING.sub_train <subarray list> <data set> <analysis parameter file> [qsub options] [direction (e.g. _180deg)] [job_dir]"
   echo ""
   echo "  <subarray list>   text file with list of subarray IDs"
   echo
   echo "  <data set>         e.g. cta-ultra3, ISDC3700, ...  "
   echo
   echo "  <direction>        e.g. for north: \"_180deg\", for south: \"_0deg\", for all directions: no option"
   echo
   exit
fi

#######################################
# read values from parameter file
ANAPAR=$3
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
RECID=$(grep RECID "$ANAPAR" | awk {'print $2'})
DSET=$2
echo "Analysis parameter: " "$NIMAGESMIN" "$ANADIR" "$DSET"
VARRAY=$(awk '{printf "%s ",$0} END {print ""}' "$1")

# batch farm submission options
QSUBOPT=${5:-$QSUBOPT}
QSUBOPT=${QSUBOPT//_X_/ }
QSUBOPT=${QSUBOPT//_M_/-}
QSUBOPT=${QSUBOPT//\"/}
# log dir
DATE=$(date +"%y%m%d")
LDIR=$CTA_USER_LOG_DIR/$DATE/XGBSTEREOTRAINING/
LDIR=${6:-$LDIR}

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
FSCRIPT="CTA.XGBSTEREO.qsub_train"

###############################################################
# loop over all arrays
for ARRAY in $VARRAY
do
   echo "STARTING $DSET ARRAY $ARRAY"

   ODIR=$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/XGB_stereo
   mkdir -p "$ODIR"
   # training list identical to TMVA gamma/hadron signal training
   SIGNALTRAINLIST=${ODIR}/training_files.list
   rm -f "${SIGNALTRAINLIST}"
   ls -1 $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/gamma_cone."$ARRAY"_ID"$RECID"*.mscw.root | sort -g | awk 'NR % 3 != 0' > "${SIGNALTRAINLIST}"

  FNAM=$LDIR/$FSCRIPT.$DSET.$ARRAY.ID${RECID}
  sed -e "s|MSCWLIST|$SIGNALTRAINLIST|" \
      -e "s|DATASET|$DSET|" \
      -e "s|OUTPUTDIR|$ODIR|" $FSCRIPT.sh > $FNAM.sh
  chmod u+x $FNAM.sh
  echo "SCRIPT $FNAM.sh"

# submit job to queue
  if [[ $SUBC == *qsub* ]]; then
      qsub $QSUBOPT -V -l h_cpu=${h_cpu} -l h_rss=${h_vmem} -l tmpdir_size=${tmpdir_size} -o $QLOG -e $QLOG "$FNAM.sh"
  elif [[ $SUBC == *condor* ]]; then
      ./condorSubmission.sh ${FNAM}.sh $h_vmem $tmpdir_size
  fi
done
