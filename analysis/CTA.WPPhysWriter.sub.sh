#!/bin/bash
#
# script to write CTA WP Phys Files
#
#######################################################################
SUBC="condor"
h_cpu="6:29:00"
h_vmem="10000M"
tmpdir_size="1G"

if [ $# -lt 7 ]
then
   echo
   echo "./CTA.WPPhysWriter.sh <sub array list> <directory with effective areas> <observation time> <output file name> <offset=0/1> <recid> <data set> [off-axis fine binning (default=FALSE)] [name] [job_dir] [qsub options]"
   echo
   echo "  <sub array list>          text file with list of subarray IDs"
   echo ""
   echo " <observation time>         observation time (add unit, e.g. 5h, 5m, 5s)"
   echo ""
   echo " <output file name>         output file name (without.root)"
   echo ""
   exit
fi

DDIR=$2
OBSTIME=$3
OUTNAME=$4
OFFSET=$5
RECID=$6
DSET=$7
BFINEBINNING=FALSE
if [ -n "$8" ]; then
   BFINEBINNING="$8"
fi

PNAME=""
if [ -n $9 ]; then
   PNAME="$9"
fi

# log files
DATE=`date +"%y%m%d"`
FDIR=${CTA_USER_LOG_DIR}/$DATE/WPPHYSWRITER/
if [ -n ${10} ]; then
    FDIR="${10}"
fi
mkdir -p ${FDIR}
echo "log directory: " ${FDIR}

QSUBOPT=""
if [ -n ${11} ]; then
   QSUBOPT="${11}"
fi
QSUBOPT=${QSUBOPT//_X_/ }
QSUBOPT=${QSUBOPT//_M_/-}

############################################################################
# software paths
source ../setSoftwarePaths.sh $DSET
# checking the path for binary
if [ -z ${EVNDISPSYS} ]
then
    echo "no EVNDISPSYS env variable defined"
    exit
fi

# script name template
FSCRIPT="CTA.WPPhysWriter.qsub"

###############################################################
# loop over all arrays
echo $VARRAY
VARRAY=`awk '{printf "%s ",$0} END {print ""}' $1`
for ARRAY in $VARRAY
do
   echo "STARTING ARRAY $ARRAY"

   if [[ -z ${PNAME} ]]; then
       ODIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/Phys/"
   else
       ODIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/Phys-${PNAME}/"
   fi
   mkdir -p $ODIR

   OXUTNAME=${ODIR}/${OUTNAME}
   echo "WP Phys file written to $OXUTNAME"

   FNAM=${FDIR}/$FSCRIPT-$ARRAY-$DSET-$OBSTIME-$(basename $OXUTNAME).sh
   cp -f $FSCRIPT.sh $FNAM

   echo "run script $FNAM"

   sed -i -e "s|ARRAY|$ARRAY|" \
       -e "s|DDIR|$DDIR|" \
       -e "s|OBSTIME|$OBSTIME|" \
       -e "s|OUTNAME|$OXUTNAME|" \
       -e "s|OFFSET|$OFFSET|" \
       -e "s|ODIR|$ODIR|" \
       -e "s|OFAXISFB|$BFINEBINNING|" \
       -e "s|RRRR|$RECID|" $FNAM

   if [[ $SUBC == *qsub* ]]; then
       qsub $QSUBOPT -V \
           -l h_cpu=${h_cpu} -l h_rss=${h_vmem} -l tmpdir_size=${tmpdir_size} \
           -o $FDIR -e $FDIR "$FNAM"
   elif [[ $SUBC == *condor* ]]; then
       ./condorSubmission.sh ${FNAM} $h_vmem $tmpdir_size
   fi
done
