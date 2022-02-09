#!/bin/sh
# Merge IPR graphs from NSB simulations
# and add log files to merged root file
#
# Requires an Eventdisplay installation
# including all environmental variables
#
# Change the two variables at the top:
#  SCRATCH: scratch space to save the output
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time

SCRATCH="$CTA_USER_DATA_DIR/tmp/"
CDIR=$(pwd)

ZE="20"
# ZE="60"

MOONOPT="" # Set to -DHALFMOON for half moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

IPRFILE="prod5${MOON}-ze-${ZE}-IPR.root"

# list of files to be merged
FLIST=${SCRATCH}/pedestals-${MOON}-ze-${ZE}.list
rm -f ${FLIST}
find $SCRATCH -name "pedestal*${MOON}-ze-${ZE}*.pedestal.root" > ${FLIST}
echo "IPR files to be merged (from ${FLIST}):"
cat ${FLIST}

# merge IPR graphs
root -l -q -b 'mergeIPRGraphs.C( '\"$IPRFILE\"', '\"$FLIST\"' )'

# add log files
for logFileNow in $(ls ${SCRATCH}/pedestal*${MOON}*"ze-"${ZE}*.log)
do
    logFile=$(basename -- "$logFileNow")
    fileTitle="${logFile%.*}"
    echo "Adding $logFile as log-$fileTitle"
    $EVNDISPSYS/bin/logFile log-$fileTitle ${IPRFILE} $logFileNow
done
