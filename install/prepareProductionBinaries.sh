#!/bin/bash
#
# script to compile Eventdisplay for a certain prodX production
#
# requires access to hessioxx at MPIK
#
#
if [ ! -n "$1" ]
then
    echo "./setSoftwarePaths.sh <data set>"
    echo
    exit
fi

DSET="$1"

# parameter and configuration files
AUXDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/"
mkdir -p $AUXDIR
cd $AUXDIR
rm -rf Eventdisplay_AnalysisFiles_CTA
echo "Analysis file installation into $AUXDIR/Eventdisplay_AnalysisFiles_CTA/"
git clone https://github.com/Eventdisplay/Eventdisplay_AnalysisFiles_CTA.git

# everything below is code

EVNDISPSYS="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/code/"
rm -rf $EVNDISPSYS
mkdir -p $EVNDISPSYS
echo "Software installation into $EVNDISPSYS"

echo "Preparing binaries for $DSET"

echo 
echo "Getting Eventdisplay..."
cd $EVNDISPSYS
git clone https://github.com/Eventdisplay/Eventdisplay.git .

# HESSIOSYS
HESSPACKAGE="hessioxxx_2019-09-04.tar.gz"
wget https://www.mpi-hd.mpg.de/hfm/CTA/MC/Software/$HESSPACKAGE
tar -xvzf $HESSPACKAGE
cd hessioxxx

if [[ $DSET = *"prod3"* ]]
then
    if [[ $DSET = *"paranal"* ]]
    then
        export HESSIOCFLAGS="-DCTA -DCTA_PROD3_MERGE"
    elif [[ $DSET = *"LaPalma"* ]]
    then
        export HESSIOCFLAGS="-DCTA -DCTA_PROD3_DEMO"
    else
        echo "unknown data"
        exit
    fi
elif [[ $DSET = *"prod4"* ]]
then
   export HESSIOCFLAGS="-DCTA -DCTA_PROD3_MERGE"
else
   echo "unknown production"
   exit
fi
make EXTRA_DEFINES="${HESSIOCFLAGS}"

cd $EVNDISPSYS
rm -f hessioxxx_2019-09-04.tar.gz

export HESSIOSYS=$EVNDISPSYS/hessioxxx

export LD_LIBRARY_PATH=$HESSIOSYS/lib:${LD_LIBRARY_PATH}

cd $EVNDISPSYS
source ./setObservatory.sh CTA

# get and compile sofa
./install_sofa.sh
export SOFASYS=$EVNDISPSYS/sofa

# compile eventdisplay
make CTA
