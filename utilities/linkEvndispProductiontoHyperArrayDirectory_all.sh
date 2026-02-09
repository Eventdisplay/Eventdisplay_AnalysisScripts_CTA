
LIST="../prod6/subArray.prod6.NorthAlphab.list"
DSET="prod6-LaPalma-ZEdeg-NSB-sq51-LL"

for Z in 20 40 52 60; do
    for N in dark moon; do
        FSET=${DSET/ZE/$Z}
        FSET=${FSET/NSB/$N}
        echo $FSET
        ./linkEvndispProductiontoHyperArrayDirectory.sh $FSET $FSET $LIST North
    done
 done
