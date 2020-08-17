#!/bin/bash
#
# set software paths to analysis paths
#

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
   echo "source ./setSoftwarePaths.sh <data set>"
   echo "(use source)"
   exit
fi

if [ ! -n "$1" ]
then
    echo "source ./setSoftwarePaths.sh <data set>"
    echo
    return
fi

TDIR=$(pwd)

# main working directory
DSET="${1}"
MAINDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}"

# ROOT installation expected
if [[ -z ${ROOTSYS} ]]; then
   echo "Error: ROOTSYS not set"
   return
fi
cd $ROOTSYS
source ./bin/thisroot.sh
cd $TDIR
ROOTCONF=`root-config --libdir`
export LD_LIBRARY_PATH=${ROOTCONF}

# EVNDISPSYS settings
if [[ -e ${MAINDIR}/code ]]; then
    EVNDISPSYS="${MAINDIR}/code"
else
    EVNDISPSYS="${MAINDIR}/Eventdisplay/"
fi
if [ ! -e ${EVNDISPSYS} ]
then
   echo "Error: directory with software not found"
   echo ${EVNDISPSYS}
   return
fi

export LD_LIBRARY_PATH=${EVNDISPSYS}/obj:${LD_LIBRARY_PATH}
if [[ -e ${EVNDISPSYS}/hessioxxx ]]; then
    export HESSIOSYS=${EVNDISPSYS}/hessioxxx
else
    export HESSIOSYS=${MAINDIR}/hessioxxx
fi
export LD_LIBRARY_PATH=$HESSIOSYS/lib:${LD_LIBRARY_PATH}

if [ $VBFSYS ]
then
    export LD_LIBRARY_PATH=$VBFSYS/lib:${LD_LIBRARY_PATH}
fi
export ROOT_INCLUDE_PATH=${EVNDISPSYS}/inc

export CTA_EVNDISP_AUX_DIR=${MAINDIR}/Eventdisplay_AnalysisFiles_CTA/
export CTA_USER_LOG_DIR="${MAINDIR}/LOGS/"

export SOFASYS=${EVNDISPSYS}/sofa
