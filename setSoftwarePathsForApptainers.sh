#!/bin/bash
#
# set software paths to analysis paths
# (usage of apptainers)
#

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
   echo "source ./setSoftwarePathsForApptainers.sh.sh <data set>"
   echo "(use source)"
   exit
fi

if [ ! -n "$1" ]
then
    echo "source ./setSoftwarePathsForApptainers.sh .sh <data set>"
    echo
    return
fi

TDIR=$(pwd)

# main working directory (logs and code)
DSET="${1}"
export WORKDIR="${CTA_USER_WORK_DIR%/}/analysis/AnalysisData/${DSET}"

# Eventdisplay settings
export EVNDISP_APPTAINER="${CTA_USER_WORK_DIR%/}/analysis/AnalysisData/APPTAINERS/eventdisplay_20240409-144727-cta-prod5.sif"
export EVNDISPSYS="apptainer exec --cleanenv ${EVNDISP_APPTAINER} /eventdisplay_workdir/Eventdisplay/"

export CTA_EVNDISP_AUX_DIR=${WORKDIR}/Eventdisplay_AnalysisFiles_CTA/
export OBS_EVNDISP_AUX_DIR=${CTA_EVNDISP_AUX_DIR}
export CTA_USER_LOG_DIR="${WORKDIR}/LOGS/"
