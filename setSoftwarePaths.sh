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

# SL7 export ROOTSYS=/afs/ifh.de/group/cta/cta/software/root/root-6.20.04_build/
export ROOTSYS=/afs/ifh.de/group/cta/cta/software/root/root_v6.30.02.Linux-almalinux9.3-x86_64-gcc11.4/

# main working directory (logs and code)
DSET="${1}"
export WORKDIR="${CTA_USER_WORK_DIR%/}/analysis/AnalysisData/${DSET}"
# main data results
# export DATADIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}"

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
if [[ -d ${WORKDIR}/code/Eventdisplay/ ]]; then
    export EVNDISPSYS="${WORKDIR}/code/Eventdisplay/"
elif [[ -d ${WORKDIR}/code ]]; then
    export EVNDISPSYS="${WORKDIR}/code"
else
   echo "Error: directory with software not found"
   echo ${WORKDIR}
   return
fi

export LD_LIBRARY_PATH=${EVNDISPSYS}/obj:${LD_LIBRARY_PATH}
if [[ -e ${EVNDISPSYS}/hessioxxx ]]; then
    export HESSIOSYS=${EVNDISPSYS}/hessioxxx
else
    export HESSIOSYS=${WORKDIR}/code/hessioxxx
fi
export LD_LIBRARY_PATH=$HESSIOSYS/lib:${LD_LIBRARY_PATH}

if [ $VBFSYS ]
then
    export LD_LIBRARY_PATH=$VBFSYS/lib:${LD_LIBRARY_PATH}
fi
export ROOT_INCLUDE_PATH=${EVNDISPSYS}/inc

export CTA_EVNDISP_AUX_DIR=${WORKDIR}/Eventdisplay_AnalysisFiles_CTA/
export OBS_EVNDISP_AUX_DIR=${CTA_EVNDISP_AUX_DIR}
export CTA_USER_LOG_DIR="${WORKDIR}/LOGS/"

export SOFASYS=${EVNDISPSYS}/sofa
