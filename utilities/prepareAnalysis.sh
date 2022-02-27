#!/bin/bash
#
# prepare analysis package into a new directory:
# - links hyper array evndisp files
# - links for sub array directories
# - analysis files
# - code compilation

if [ ! -n "$1" ]; then
    echo "
./prepareAnalysis.sh <data set>

    "
    exit
fi
DSET="$1"
DDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}"
mkdir -p "$DDIR" || return

gethyperarraylink()
{
    if [[ ${DSET} == *"LaPalma-20deg-NSB5x"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_LaPalma_AdvancedBaseline_NSB5x_20deg_DL1"
    elif [[ ${DSET} == *"LaPalma-20deg"* ]]; then
        echo "/lustre/fs24/group/cta/prod5b/CTA-ProdX-Download-DESY/Prod5b_LaPalma_AdvancedBaseline_NSB1x"
    elif [[ ${DSET} == *"LaPalma-40deg-NSB5x"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_LaPalma_AdvancedBaseline_NSB5x_40deg_DL1"
    elif [[ ${DSET} == *"LaPalma-40deg"* ]]; then
        echo "/lustre/fs24/group/cta/prod5b/CTA-ProdX-Download-DESY/Prod5b_LaPalma_AdvancedBaseline_NSB1x_40deg"
    elif [[ ${DSET} == *"LaPalma-60deg-NSB5x"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_LaPalma_AdvancedBaseline_NSB5x_60deg_DL1"
    elif [[ ${DSET} == *"LaPalma-60deg"* ]]; then
        echo "/lustre/fs24/group/cta/prod5b/CTA-ProdX-Download-DESY/Prod5b_LaPalma_AdvancedBaseline_NSB1x_60deg"
    elif [[ ${DSET} == *"Paranal-20deg-NSB5x"* ]]; then
        echo "/lustre/fs22/group/cta/users/maierg/analysis/AnalysisData/prod5-Paranal-20deg-NSB5x-sq10-LL/S.hyperarray/EVNDISP"
    elif [[ ${DSET} == *"Paranal-20deg"* ]]; then
        echo "/lustre/fs22/group/cta/users/maierg/analysis/AnalysisData/prod5-Paranal-20deg-sq10-LL/S.hyperarray/EVNDISP"
    elif [[ ${DSET} == *"Paranal-40deg-NSB5x"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_Paranal_AdvancedBaseline_NSB5x_40deg_DL1"
    elif [[ ${DSET} == *"Paranal-40deg"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_Paranal_AdvancedBaseline_NSB1x_40deg_DL1"
    elif [[ ${DSET} == *"Paranal-60deg-NSB5x"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_Paranal_AdvancedBaseline_NSB5x_60deg_DL1"
    elif [[ ${DSET} == *"Paranal-60deg"* ]]; then
        echo "/lustre/fs21/group/cta/prod5-grid/Prod5b_Paranal_AdvancedBaseline_NSB1x_60deg_DL1"
    fi
}

linkhyperarray()
{
    cd "$DDIR"
    if [[ ${DSET} == *"LaPalma"* ]]; then
        mkdir -v -p "N.hyperarray" || return
        cd "N.hyperarray"
    else
        mkdir -v -p "S.hyperarray" || return
        cd "S.hyperarray"
    fi
    gethyperarraylink
    HLINK=$(gethyperarraylink)
    rm -f EVNDISP
    ln -s "$HLINK" EVNDISP
}

linksubarrays()
{
    if [[ ${DSET} == *"LaPalma"* ]]; then
        ./linkEvndispProduction.sh "${DSET}" "${DSET}" \
            ../prod5/subArray.prod5.North-Alpha.list North
        ./linkEvndispProduction.sh "${DSET}" "${DSET}" \
            ../prod5/subArray.prod5.North-Alpha-sub.list North
    else
        ./linkEvndispProduction.sh "${DSET}" "${DSET}" \
            ../prod5/subArray.prod5.South-AlphaC8aj-BetaPlus.list South
        ./linkEvndispProduction.sh "${DSET}" "${DSET}" \
            ../prod5/subArray.prod5.South-AlphaC8aj-BetaPlus-sub.list South
    fi
}

install()
{
    cd ../install || return
    ./prepareProductionBinaries.sh "${DSET}" main
}

(
linkhyperarray
)

(
linksubarrays
)

(
install
)

