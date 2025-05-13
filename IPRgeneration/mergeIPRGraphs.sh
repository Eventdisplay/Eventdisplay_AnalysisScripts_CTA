#!/bin/sh
# Merge IPR graphs from NSB simulations
# and add log files to merged root file
#
# Requires an Eventdisplay installation
# including all environmental variables
#

if [ $# -lt 2 ]; then
    echo "
    ./mergeIPRGraphs.sh <directory with data products (pedestal files)> <IPR file>
    "
    exit
fi
SCRATCH=${1}
IPRFILE=${2}
CDIR=$(pwd)

# list of files to be merged
FLIST="${SCRATCH}/pedestals.list"
rm -f ${FLIST}
find $SCRATCH -name "*.pedestal.root" | sort  > ${FLIST}
echo "IPR files to be merged (from ${FLIST}):"
cat ${FLIST}

# merge IPR graphs
root -l -q -b 'mergeIPRGraphs.C( '\"$IPRFILE\"', '\"$FLIST\"' )'

# add log files
LOGFILES=$(find $SCRATCH -name "*.log" | sort)
for logFileNow in $LOGFILES
do
    logFile=$(basename -- "$logFileNow")
    fileTitle="${logFile%.*}"
    echo "Adding $logFile as log-$fileTitle"
    $EVNDISPSYS/bin/logFile log-$fileTitle ${IPRFILE} $logFileNow
done
