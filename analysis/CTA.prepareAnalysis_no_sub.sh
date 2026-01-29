#!/bin/bash
#
# script to prepare event files for analysis (average AZ only)
#
#
#

if [ $# -lt 3 ]
then
   echo
   echo "CTA.prepareAnalysis_no_sub.sh <subarray list> <data set> <analysis parameter file>"
   echo ""
   echo "  <subarray list>   text file with list of subarray IDs"
   echo
   echo "  <data set>         e.g. cta-ultra3, ISDC3700, ...  "
   echo
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
ANADIR=$(grep MSCWSUBDIRECTORY  "$ANAPAR" | awk {'print $2'})
DSET=$2
echo "Analysis parameter: " "$ANADIR" "$DSET"
VARRAY=$(awk '{printf "%s ",$0} END {print ""}' "$1")

######################################
# software paths
source ../setSoftwarePaths.sh "$DSET"
# checking the path for binary
if [ -z "$EVNDISPSYS" ]
then
    echo "no EVNDISPSYS env variable defined"
    exit
fi

###############################################################
# loop over all arrays
for ARRAY in $VARRAY
do
    echo "STARTING $DSET ARRAY $ARRAY"
    ##########################################################
    # set links for events used in effective area calculation
    # (separate training and events used for analysis)
    ANAEFF_noAZ="$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/${ANADIR}.EFFAREA.MCAZ"
    rm -rf "$ANAEFF_noAZ"
    mkdir -p "$ANAEFF_noAZ"
    for MCAZ in "_0deg" "_180deg"
    do
        ANAEFF="$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/${ANADIR}.EFFAREA.MCAZ${MCAZ}"
        echo "ORG $ANAEFF"
        echo "TARG $ANAEFF_noAZ"
        find "$ANAEFF" -name "*.root" -exec ln -s -t "$ANAEFF_noAZ" {} +
    done
done
