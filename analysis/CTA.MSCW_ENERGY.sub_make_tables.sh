#!/bin/sh
#
# make tables for CTA
#
#
#
#

SUBC="condor"
h_cpu="47:29:00"
h_vmem="8000M"
tmpdir_size="1G"


if [ $# -lt 6 ]
then
   echo
   echo "CTA.MSCW_ENERGY.sub_make_tables.sh <table file name> <recid> <subarray list> <onSource/cone> <data set> <azimuth bin> [min tel] [qsub options] [job_dir]"
   echo ""
   echo "  <table file name>  name of the table file (to be written; without .root)"
   echo "  <recid>            reconstruction ID according to EVNDISP.reconstruction.parameter"
   echo "  <subarray list>    text file with list of subarray IDs"
   echo "  <onSource/cone>    calculate tables for on source or different wobble offsets"
   echo "  <data set>         e.g. cta-ultra3, ISDC3700m, ...  "
   echo "  <azimuth bin>      e.g. _180deg, _0deg"
   echo "  [min tel]          minimum number of telescopes (any type)"
   echo
   echo " input data and output directories for tables are fixed in CTA.MSCW_ENERGY.qsub_make_tables.sh"
   echo
   echo " tables create for different wobble offsets can be combined with CTA.MSCW_ENERGY.combine_tables.sh"
   echo
   exit
fi

#########################################
# input parameters
#########################################
TFIL=$1
RECID=$2
VARRAY=`awk '{printf "%s ",$0} END {print ""}' $3`
CONE="FALSE"
if [ $4 == "cone" ]
then
  CONE="TRUE"
fi
DSET=$5
AZ=$6
[[ "$7" ]] && MINTEL=$7 || MINTEL="4"
if [ -n $8 ]
then
   QSUBOPT="$8"
fi
QSUBOPT=${QSUBOPT//_X_/ }
QSUBOPT=${QSUBOPT//_M_/-}

#########################################
# software paths
echo $DSET
source ../setSoftwarePaths.sh $DSET
# checking the path for binary
if [ -z $EVNDISPSYS ]
then
    echo "no EVNDISPSYS environmental variable defined"
    exit
fi
DATE=`date +"%y%m%d"`
# checking if table already exists
# archive this table
if [ -e $TFIL.root ]
then
   mv -f $TFIL.root ${TFIL}.${DATE}.root
   echo "archived existing table file to ${TFIL}.${DATE}.root"
fi

# adjust table name for on-axis tables

#########################################
# output directory for error/output from batch system
# in case you submit a lot of scripts: QLOG=/dev/null
QLOG=$CTA_USER_LOG_DIR/$DATE/MAKETABLES/
SHELLDIR=$CTA_USER_LOG_DIR/$DATE/MAKETABLES/
if [ -n ${9} ]; then
    QLOG=${9}
    SHELLDIR=${QLOG}
fi
mkdir -p $QLOG
mkdir -p $SHELLDIR

# skeleton script
FSCRIPT="CTA.MSCW_ENERGY.qsub_make_tables"

#########################################
# loop over all arrays
#########################################
for ARRAY in $VARRAY
do
   echo "STARTING ARRAY $ARRAY"

# table file
  TAFIL=$TFIL

# run scripts
  FNAM="$SHELLDIR/EMSCW.table-$TAFIL-W$MEANDIST-${ARRAY}${AZ}"
  cp $FSCRIPT.sh $FNAM.sh
  cp $FSCRIPT.sh $FNAM.sh

  sed -i -e "s|TABLEFILE|$TAFIL|" \
         -e "s|RECONSTRUCTIONID|$RECID|" \
         -e "s|ARRRRRRR|$ARRAY|" \
         -e "s|CCC|$CONE|" \
         -e "s|AZIMUTH|$AZ|" \
         -e "s|MMTEL|$MINTEL|" \
         -e "s|DATASET|$DSET|" $FNAM.sh

  chmod u+x $FNAM.sh
  echo "shell script " $FNAM.sh

# submit the job
  if [[ $SUBC == *qsub* ]]; then
       qsub $QSUBOPT -l h_cpu=${h_cpu} -l h_rss=${h_vmem} -V -o $QLOG/ -e $QLOG/ "$FNAM.sh"
  elif [[ $SUBC == *condor* ]]; then
       ./condorSubmission.sh "${FNAM}.sh" $h_vmem $tmpdir_size
  fi
done

echo "shell scripts are written to $SHELLDIR"
echo "batch output and error files are written to $QLOG"


exit
