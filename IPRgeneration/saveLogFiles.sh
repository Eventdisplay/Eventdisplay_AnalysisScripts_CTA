#!/bin/sh
# Add all log files to merged root file
#
# Requires an Eventdisplay installation
# including all environmental variables
#
# Change the two variables at the top:
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time

MOONOPT="" # Set to -DHALFMOON for half moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

for logFileNow in $(ls *.log)
do
    logFile=$(basename -- "$logFileNow")
    fileTitle="${logFile%.*}"
    $EVNDISPSYS/bin/logFile log-$fileTitle prod5${MOON}-IPR.root $logFile
done
