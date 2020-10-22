#!/bin/sh
#
# script to analyse CTA MC files with lookup tables
#
#


if [ $# -lt 7 ]
then
   echo
   echo "CTA.MSCW_ENERGY.sub_analyse_MC.sh <tablefile> <recid> <subarray list> <data set> <output directory> <onSource/cone> <azimuth bin> <minimage> [qsub options]"
   echo
   echo "  <tablefile>     table file name (without .root)"
   echo "                  expected file name: xxxxxx-SUBARRAY.root; SUBARRAY is added by this script"
   echo "  <recid>         reconstruction ID"
   echo "  <subarraylist > text file with list of subarray IDs"
   echo "  <data set>      e.g. ultra, ISDC3700m, ..."
   echo "  <output directory> mscw files are written into this directory"
   echo "  <azimuth bin>      e.g. _180deg, _0deg"
   echo
   exit
fi

#########################################
# input parameters
TABLE=$1
RECID=$2
VARRAY=`awk '{printf "%s ",$0} END {print ""}' $3`
DSET="$4"
CONE="FALSE"
if [[ $6 == "cone" ]]
then
  CONE="TRUE"
fi
ANADIR=$5
if [ $CONE = "FALSE" ]
then
   ANADIR=$ANADIR-onAxis
fi
MCAZ=$7
MINIMAGE=$8
QSUBOPT=""
if [ -n $9 ]
then
   QSUBOPT="$9"
fi
QSUBOPT=${QSUBOPT//_X_/ } 
QSUBOPT=${QSUBOPT//_M_/-} 

#########################################
# software paths
source ../setSoftwarePaths.sh $DSET
# checking the path for binary
if [ -z $EVNDISPSYS ]
then
    echo "no EVNDISPSYS env variable defined"
    exit
fi

#########################################
# output directory for error/output from batch system
# in case you submit a lot of scripts: QLOG=/dev/null
DATE=`date +"%y%m%d"`
QLOG=$CTA_USER_LOG_DIR/$DATE/ANALYSETABLES/
mkdir -p $QLOG
# QLOG=/dev/null

# output directory for shell scripts
SHELLDIR="$QLOG/$ANADIR/"
mkdir -p $SHELLDIR

###########################
# particle types
VPART=( "gamma_onSource" "gamma_cone" "electron" "proton" )
NPART=${#VPART[@]}

###########################
# MC azimuth angles
MCAZ=${MCAZ/_/}

#########################################
#loop over all arrays
#########################################
for SUBAR in $VARRAY
do
   echo "STARTING ARRAY $SUBAR"

# output directory
   ODIR=$CTA_USER_DATA_DIR"/analysis/AnalysisData/"$DSET"/"$SUBAR"/"${ANADIR}
   mkdir -p ${ODIR}

#########################################
# loop over all particle types
   for ((m = 0; m < $NPART; m++ ))
   do
         PART=${VPART[$m]}

# delete all old files (data and log files) for the particle type and azimuth angle
         rm -f ${ODIR}/${PART}*ID${RECID}_${MCAZ}*

# take $FILEN files and combine them into one mscw file
	 FILEN=250
	 if [ $PART = "proton" ]
	 then
	    FILEN=1000
	 fi

#########################################
# input files lists

         TMPLIST=${ODIR}/$PART$NC"."$SUBAR"_ID"${RECID}${MCAZ}"-"$DSET".list"
	 rm -f $TMPLIST
	 echo $TMPLIST ${MCAZ}
	 find $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$SUBAR/EVNDISP/$PART/ -name "*[0-9]*[\.,_]${MCAZ}*.root" > $TMPLIST
	 NTMPLIST=`wc -l $TMPLIST | awk '{print $1}'`
	 echo "total number of files for particle type $PART ($MCAZ) : $NTMPLIST"
         NJOBTOT=$(( NTMPLIST / FILEN + 1))
         echo "total number of jobs: $NJOBTOT"

# output file name for mscw_energy
         TFIL=$PART$NC"."$SUBAR"_ID${RECID}_${MCAZ}-"$DSET

# skeleton script
        FSCRIPT="CTA.MSCW_ENERGY.qsub_analyse_MC"

# name of script actually submitted to the queue
        FNAM="$SHELLDIR/MSCW.ana-$DSET-ID$RECID-$PART-array$SUBAR-$6"

        sed -e "s|TABLEFILE|$TABLE|" \
            -e "s|TTTTFIL|$TFIL|" \
            -e "s|RECONSTRUCTIONID|$RECID|" \
            -e "s|ARRAYYY|$SUBAR|" \
            -e "s|DATASET|$DSET|" \
            -e "s|AZIMUTH|$MCAZ|" \
            -e "s|FILELIST|${TMPLIST}|" \
            -e "s|FILELENGTH|$FILEN|" \
            -e "s|NNNIMAGE|$MINIMAGE| " \
            -e "s|AAAAADIR|$ANADIR|" $FSCRIPT.sh > $FNAM.sh 

        chmod u+x $FNAM.sh
        echo "run script written to $FNAM.sh"
        echo "queue log and error files written to $QLOG"

# submit the job
        qsub $QSUBOPT -t 1-$NJOBTOT:1 -l h_cpu=11:29:00 -l h_rss=4000M -l tmpdir_size=10G -V -o $QLOG -e $QLOG "$FNAM.sh" 
   done
done

exit

