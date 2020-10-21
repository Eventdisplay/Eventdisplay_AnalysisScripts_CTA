#!/bin/bash
#
# script to compile Eventdisplay for a certain prodX production
#
# requires access to hessioxx at MPIK
#
#
if [ ! -n "$1" ]
then
    echo "././prepareProductionBinaries.sh data set>"
    echo
    echo "   will install hessioxx, Eventdisplay analysis files and code"
    echo
    exit
fi

DSET="$1"
TDIR=$(pwd)

VERSION="prod5-v08"

# parameter and configuration files
AUXDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/"
mkdir -p $AUXDIR
cd $AUXDIR
rm -rf Eventdisplay_AnalysisFiles_CTA
echo "Analysis file installation into $AUXDIR/Eventdisplay_AnalysisFiles_CTA/"
git clone -b ${VERSION} https://github.com/Eventdisplay/Eventdisplay_AnalysisFiles_CTA.git

# everything below is code
EVNDISPSYS="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/code/"
rm -rf $EVNDISPSYS
mkdir -p $EVNDISPSYS
echo "Software installation into $EVNDISPSYS"

echo "Preparing binaries for $DSET"

echo 
echo "Getting Eventdisplay..."
cd $EVNDISPSYS
git clone -b ${VERSION} https://github.com/Eventdisplay/Eventdisplay.git .

# HESSIOSYS
HESSPACKAGE="hessioxxx.tar.gz"
if [[ ! -e ${HESSPACKAGE} ]]; then
    wget https://www.mpi-hd.mpg.de/hfm/CTA/MC/Software/Testing/$HESSPACKAGE
fi
tar -xvzf $HESSPACKAGE
cd hessioxxx

# FLAGS for hessioxx and Eventdisplay compilation
if [[ $DSET = *"prod3"* ]]
then
    if [[ $DSET = *"paranal"* ]]
    then
        export HESSIOCFLAGS="-DCTA -DCTA_PROD3_MERGE"
        EFLAGS="PROD3b_South"
    elif [[ $DSET = *"LaPalma"* ]]
    then
        export HESSIOCFLAGS="-DCTA -DCTA_PROD3_DEMO"
        EFLAGS="PROD3b_North"
    else
        echo "unknown data"
        exit
    fi
elif [[ $DSET = *"prod4"* ]]
then
   export HESSIOCFLAGS="-DCTA -DCTA_PROD3_MERGE"
   EFLAGS="PROD5"
elif [[ $DSET = *"prod5"* ]]
then
   export HESSIOCFLAGS="-DCTA_PROD4 -DMAXIMUM_TELESCOPES=180 -DWITH_GSL_RNG"
   EFLAGS="PROD5"
else
   echo "unknown production"
   exit
fi
make EXTRA_DEFINES="${HESSIOCFLAGS}"
cd $EVNDISPSYS
rm -f hessioxxx.tar.gz

# install sofa
./install_sofa.sh

# set all flags
cd ${TDIR}
source  ../setSoftwarePaths.sh ${DSET}

# compile eventdisplay
cd $EVNDISPSYS
make CTA CTAPROD=$EFLAGS GRIDPROD=CTAGRID

cd ${TDIR}
