#!/bin/bash
#
# script to compile Eventdisplay for a certain prodX production
#
# requires access to hessioxx at MPIK
#
#

if [ $# -lt 1 ]; then
    echo "
./prepareProductionBinaries.sh <data set> <Eventdisplay version>

   will install hessioxx, Eventdisplay analysis files and code

   requires same branch names for all relevant Eventdisplay Repositories
   (or main)

   "
   exit
fi
set -e

DSET="$1"
[[ "$2" ]] && VERSION=$2 || VERSION="main"
TDIR=$(pwd)

echo "Installing $DSET for Eventdisplay version $VERSION"

# remove later: forwas used for prod5
# VERSION="prod5-sq20"
if [[ $DSET = *"SCT-sq11-LL"* ]]; then
   VERSION="prod3b-v11"
fi

install_analysis_files()
{
    # parameter and configuration files
    AUXDIR="$CTA_USER_WORK_DIR/analysis/AnalysisData/${DSET}/"
    mkdir -p $AUXDIR
    cd $AUXDIR
    rm -rf Eventdisplay_AnalysisFiles_CTA
    echo "Analysis file installation into $AUXDIR/Eventdisplay_AnalysisFiles_CTA/"
    if [[ $VERSION == "main" ]]; then
        git clone git@github.com:Eventdisplay/Eventdisplay_AnalysisFiles_CTA.git
    else
        git clone -b ${VERSION} git@github.com:Eventdisplay/Eventdisplay_AnalysisFiles_CTA.git
    fi
}

install_hessio()
{
    HESSPACKAGE="hessioxxx.tar.gz"
    if [[ ! -e ${HESSPACKAGE} ]]; then
        wget https://www.mpi-hd.mpg.de/hfm/CTA/MC/Software/Testing/$HESSPACKAGE
    fi
    tar -xvzf $HESSPACKAGE
    cd hessioxxx

    # FLAGS for hessioxx and Eventdisplay compilation
    if [[ $DSET = *"prod3"* ]]
    then
        if [[ $DSET = *"SCT"* ]]
        then
            if [[ $DSET = *"sq11"* ]]; then
                if [[ $DSET = *"156"* ]]; then
                    export HESSIOCFLAGS="-DCTA_PROD4_SC -DMAXIMUM_TELESCOPES=156"
                    export MAXTEL=156
                else
                    export HESSIOCFLAGS="-DCTA_PROD4_SC -DMAXIMUM_TELESCOPES=92"
                    export MAXTEL=92
                fi
                EFLAGS="PROD3b_SCTALPHA"
            else
                export HESSIOCFLAGS="-DCTA -DCTA_PROD3_DEMO"
                EFLAGS="PROD3b_SCT"
            fi
        elif [[ $DSET = *"paranal"* ]]
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
       EFLAGS="PROD4b"
    elif [[ $DSET = *"prod5"* ]]
    then
       export HESSIOCFLAGS="-DCTA_PROD4 -DMAXIMUM_TELESCOPES=180 -DWITH_GSL_RNG"
       EFLAGS="PROD5"
    elif [[ $DSET = *"prod6"* ]]
    then
       export HESSIOCFLAGS="-DCTA_PROD6_SC -DMAXIMUM_TELESCOPES=120 -DWITH_GSL_RNG"
       EFLAGS="PROD6"
    else
       echo "unknown production"
       exit
    fi
    make EXTRA_DEFINES="${HESSIOCFLAGS}"
    cd ..
    rm -f hessioxxx.tar.gz
}

install_analysis_files

CODEDIR="$CTA_USER_WORK_DIR/analysis/AnalysisData/${DSET}/code/"
EVNDISPSYS="${CODEDIR}/Eventdisplay"
export EVNDISPSYS="${CODEDIR}/Eventdisplay"
rm -rf ${EVNDISPSYS}
mkdir -p $CODEDIR || return
echo "Software installation into $CODEDIR"
echo "Preparing binaries for $DSET"

echo 
echo "Getting Eventdisplay..."
cd $CODEDIR
if [[ $VERSION == "main" ]]; then
    git clone git@github.com:Eventdisplay/Eventdisplay.git
else
    git clone -b ${VERSION} git@github.com:Eventdisplay/Eventdisplay.git
fi

install_hessio

cd $EVNDISPSYS
./install_sofa.sh

cd ${TDIR}
source  ../setSoftwarePaths.sh ${DSET}
cd $EVNDISPSYS
pwd
make -j 12 CTA CTAPROD=$EFLAGS GRIDPROD=CTAGRID
cd ${TDIR}
