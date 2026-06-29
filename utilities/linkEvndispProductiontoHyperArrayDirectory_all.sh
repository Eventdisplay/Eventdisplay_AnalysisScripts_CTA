#!/bin/bash
# Link EVNDISP production directories to the hyperarray directories for all data sets in the list
#
# Note that many hardwired parameters.

LIST="../prod6/subArray.prod6.SouthAlpha.list"
LIST="../prod6/subArray.prod6.SouthAlpha-sub.list"
DSET="prod6-LaPalma-ZEdeg-NSB-sq51-LL"
DSET="prod6-Paranal-ZEdeg-NSB-sq20-LL"

for Z in 20 40 52 60; do
    for N in moon; do
        FSET=${DSET/ZE/$Z}
        FSET=${FSET/NSB/$N}
        echo $FSET
        ./linkEvndispProductiontoHyperArrayDirectory.sh $FSET $FSET $LIST South
    done
 done
