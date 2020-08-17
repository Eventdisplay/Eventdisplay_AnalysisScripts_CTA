#!/bin/bash
#
# set software paths to analysis paths
#
# allow also to install all software packages
#

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
   echo "source ./setSoftwarePaths.sh <data set> [install]"
   echo "(use source)"
   exit
fi

if [ ! -n "$1" ]
then
    echo "source ./setSoftwarePaths.sh <data set> [install]"
    echo
    return
fi

#########################################
# installation of all required packages
function install_packages {

   cd "${MAINDIR}"
   # hessioxxx
   #wget https://www.mpi-hd.mpg.de/hfm/CTA/MC/Software/Testing/hessioxxx.tar.gz
   if [[ -e hessioxxx.tar.gz ]]; then
      tar -xvzf hessioxxx.tar.gz
      cd hessioxxx
      make EXTRA_DEFINES="-DCTA_PROD4 -DMAXIMUM_TELESCOPES=180 -DWITH_GSL_RNG"
      #rm -f hessioxxx.tar.gz
      cd ${MAINDIR}
  else
      echo "Error finding hessioxx"
      return
  fi
  export HESSIOSYS=${MAINDIR}/hessioxxx
  export LD_LIBRARY_PATH=$HESSIOSYS/lib:${LD_LIBRARY_PATH}

  # Eventdisplay Analysis files
  git clone https://github.com/Eventdisplay/Eventdisplay_AnalysisFiles_CTA.git

  # Eventdisplay code
  git clone https://github.com/Eventdisplay/Eventdisplay.git
  cd Eventdisplay
  EVNDISPSYS=$(pwd)
  ./install_sofa.sh
  export SOFASYS=${EVNDISPSYS}/sofa
  make CTA CTAPROD=PROD5
  cd "${TDIR}"
}

INSTALL="noinstall"
if [ -n "$2" ]
then
    INSTALL=$2
fi
echo "SETTING $1 $INSTALL"

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


# Software installation (optional)
if [[ $INSTALL == "install" ]]; then
   install_packages
   return
fi

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
