#!/bin/bash
#
# train disp for CTA
#
# called from CTA.DISPTRAINING_sub_analyse.sh
#
#

ODIR=OFILE
RECID=RECONSTRUCTIONID
TTYPE=TELTYPE
BDT=MLPTYPE
TLIST=ILIST
TMVAO=TTT
DSET="DATASET"
ARRAY=AAA
QC="QQQQ"

# set the right observatory (environmental variables)
source $EVNDISPSYS/setObservatory.sh CTA

# output data files are written to this directory
mkdir -p $ODIR

# delete old log files
rm -f $ODIR/${BDT}-${TTYPE}.training.log
# delete old training files
rm -f $ODIR/*${TTYPE}*

# array layout file

# strip array scaling (two characters) for paranal sites
DARR=${ARRAY}
if [[ $DSET == *"prod3"* ]]
then
    if [[ $DSET == *"paranal"* ]] && [[ $DSET != *"prod3b"* ]]
    then
       DARR=${ARRAY%??}
       ADIR=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3${DARR}.lis
    elif [[ $DSET == *"LaPalma"* ]] || [[ $DARR == "Sb"* ]]
    then
       DARR=${ARRAY}
       ADIR=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3${DARR}.lis
    else
       ADIR=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod3Sb${DARR:1}.lis
    fi
elif [[ $DSET == *"prod4"* ]]; then
    ADIR=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod4${DARR}.lis
elif [[ $DSET == *"prod5"* ]]; then
    ADIR=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${DARR}.lis
else
    echo "Unknown data set: $DSET"
    echo "exiting..."
    exit
fi

#########################################
# train TMVA
$EVNDISPSYS/bin/trainTMVAforAngularReconstruction $TLIST \
                                                  $ODIR \
                                                  0.8 \
                                                  ${RECID} \
                                                  ${TTYPE} \
                                                  ${BDT} \
                                                  ${TMVAO} \
                                                  ${ADIR} \
                                                  "" \
                                                  ${QC} \
                                                  0 > $ODIR/${BDT}-${TTYPE}.training.log 2>&1
#########################################

##############
# cleanup
# remove everything if telescope type is not found
if [[ -e $ODIR/${BDT}-${TTYPE}.training.log ]]; then
    if grep -Fxq "Number of telescope types: 0" $ODIR/${BDT}-${TTYPE}.training.log
    then
         echo "No telescopes found of type ${TTYPE}"
         head -n 10 ${TLIST}
    #     rm -f -v $ODIR/${BDT}"_"${TTYPE}.root
    #     rm -f $ODIR/${BDT}-${TTYPE}.training.log
    fi
fi
# move everything into root files
if [[ -e $ODIR/${BDT}_BDT_${TTYPE}.weights.xml ]]; then
    $EVNDISPSYS/bin/logFile dispXML-BDT-${TTYPE} $ODIR/${BDT}-${TTYPE}.disptmva.root $ODIR/${BDT}_BDT_${TTYPE}.weights.xml
    rm -f $ODIR/${BDT}_BDT_${TTYPE}.weights.xml
fi
if [[ -e $ODIR/${BDT}_MLP_${TTYPE}.weights.xml ]]; then
    $EVNDISPSYS/bin/logFile dispXML-MLP-${TTYPE} $ODIR/${BDT}-${TTYPE}.disptmva.root $ODIR/${BDT}_MLP_${TTYPE}.weights.xml
    rm -f $ODIR/${BDT}_MLP_${TTYPE}.weights.xml
fi
if [[ -e $ODIR/${BDT}-${TTYPE}.training.log ]]; then
    $EVNDISPSYS/bin/logFile dispLog-${TTYPE} $ODIR/${BDT}-${TTYPE}.disptmva.root $ODIR/${BDT}-${TTYPE}.training.log
#    rm -f $ODIR/${BDT}-${TTYPE}.training.log
fi

#rm -f $ODIR/${BDT}_${TTYPE}.root
#rm -f $ODIR/${BDT}_${TTYPE}.tmva.root

exit
