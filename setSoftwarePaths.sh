#!/bin/bash
#
# set software paths to the correct place

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

DSET="$1"
EVNDISPSYS="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/code/"
if [ ! -e $EVNDISPSYS ]
then
   echo "Error: directory with software not found"
   echo $EVNDISPSYS
   return
fi

TDIR=`pwd`
cd $ROOTSYS
source ./bin/thisroot.sh
cd $TDIR

ROOTCONF=`root-config --libdir`
export LD_LIBRARY_PATH=${ROOTCONF}

export LD_LIBRARY_PATH=${EVNDISPSYS}/obj:${LD_LIBRARY_PATH}
export HESSIOSYS=$EVNDISPSYS/hessioxxx
export LD_LIBRARY_PATH=$HESSIOSYS/lib:${LD_LIBRARY_PATH}

export LD_LIBRARY_PATH=/afs/ifh.de/group/cta/VERITAS/software/VBF-0.3.4/lib:${LD_LIBRARY_PATH}

export CTA_EVNDISP_AUX_DIR=$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/Eventdisplay_AnalysisFiles_CTA/
export CTA_USER_LOG_DIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/LOGS/"

export SOFASYS=${EVNDISPSYS}/sofa
