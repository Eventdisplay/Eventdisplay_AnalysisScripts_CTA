#!/bin/sh
# use for disp direction always the baseline array
# (only telescope-wise parameters are used for disp
#  direction)
#
# should be executed in the directory with all analysis results
#
#
# exiting disp training files
DISPN="1084"
# new disp training files
DISPO="1085"
# baseline array directory
FULLARRAY="BDTdisp.Nb.3AL4-BN15.T${DISPN}"

DD=$(find . -maxdepth 1 -name "BDTdisp.Nb*${DISPN}")

for D in $DD
do
    CDIR=$(pwd)

    ODIR=${D/$DISPN/$DISPO}
    echo "Linking $ODIR"
    mkdir -p $ODIR

    cd $ODIR
    if [[ ! -e BDTDispEnergy ]]; then
        ln -s ../${D}/BDTDispEnergy .
    fi
    if [[ ! -e BDTDisp ]]; then
        ln -s ../${FULLARRAY}/BDTDisp .
    fi
    if [[ ! -e BDTDispError ]]; then
        ln -s ../${FULLARRAY}/BDTDispError .
    fi

    cd $CDIR
done
