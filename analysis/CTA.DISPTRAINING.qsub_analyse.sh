#!/bin/bash
#
# train dispBDTs for CTA
#

ODIR=OODIR
DDIR=DDDIR
RECID=RECONSTRUCTIONID
TTYPE=TELTYPE
BDT=MLPTYPE
TLIST=ILIST
TMVAO=TTT
DSET="DATASET"
ARRAY=AAA
QC="QQQQ"

# set the right observatory (environmental variables)
if [ ! -n "$EVNDISP_APPTAINER" ]; then
    source "${EVNDISPSYS}"/setObservatory.sh CTA
fi

# temporary (scratch) directory
if [[ -n $TMPDIR ]]; then
  TEMPDIR=$TMPDIR/$RUN
else
  TEMPDIR="$CTA_USER_DATA_DIR/TMPDIR"
fi
echo "Scratch dir: $TEMPDIR"
mkdir -p "$TEMPDIR"

# output data files are written to this directory
# (note that $OUTPUTDIR is pointing inside the
# apptainer to a mounted directory, while $ODIR
# is not changed)
OUTPUTDIR="${ODIR}"
mkdir -p $OUTPUTDIR
# delete old log files
rm -f $OUTPUTDIR/${BDT}-${TTYPE}.training.log
# delete old training files
rm -f $OUTPUTDIR/*${TTYPE}*

# data data directory to LIST
cp -v "$TLIST" "$TEMPDIR"

if [ -n "$EVNDISP_APPTAINER" ]; then
    APPTAINER_MOUNT=" --bind ${OUTPUTDIR}:/eventdisplay_datadir/output/ "
    APPTAINER_MOUNT+=" --bind ${DDIR}:/eventdisplay_datadir/data/ "
    APPTAINER_MOUNT+=" --bind ${TEMPDIR}:/eventdisplay_datadir/tmp/ "
    echo "APPTAINER MOUNT: ${APPTAINER_MOUNT}"
    APPTAINER_ENV="--env OUTPUTDIR=/eventdisplay_datadir/data/,TEMPDIR=/eventdisplay_datadir/tmp/"
    EVNDISPSYS="${EVNDISPSYS/--cleanenv/--cleanenv $APPTAINER_ENV $APPTAINER_MOUNT}"
    echo "APPTAINER SYS: $EVNDISPSYS"
    OUTPUTDIR="/eventdisplay_datadir/output/"
    DDIR="/eventdisplay_datadir/data"
    sed -i "s|^|${DDIR}/|" "$TEMPDIR/$(basename $TLIST)"
    TEMPDIR="/eventdisplay_datadir/tmp/"
else
    sed -i "s|^|${DDIR}/|" "$TEMPDIR/$(basename $TLIST)"
fi

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
elif [[ $DSET == *"prod6"* ]]; then
    ADIR=$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod6${DARR}.lis
else
    echo "Unknown data set: $DSET, exiting"
    exit
fi

echo $OUTPUTDIR

# train TMVA
$EVNDISPSYS/bin/trainTMVAforAngularReconstruction "$TEMPDIR/$(basename $TLIST)" \
                                                  "$OUTPUTDIR" \
                                                  0.8 \
                                                  ${RECID} \
                                                  ${TTYPE} \
                                                  ${BDT} \
                                                  ${TMVAO} \
                                                  ${ADIR} \
                                                  "" \
                                                  ${QC} \
                                                  0 > # $ODIR/${BDT}-${TTYPE}.training.log 2>&1


# cleanup
# remove everything if telescope type is not found
if [[ -e $ODIR/${BDT}-${TTYPE}.training.log ]]; then
    if grep -Fxq "Number of telescope types: 0" $ODIR/${BDT}-${TTYPE}.training.log
    then
         echo "No telescopes found of type ${TTYPE}"
         head -n 10 ${TLIST}
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
if [[ -e $ODIR/${BDT}-${TTYPE}.training.log ]] && [[ -e $ODIR/${BDT}-${TTYPE}.disptmva.root ]]; then
    $EVNDISPSYS/bin/logFile dispLog-${TTYPE} $ODIR/${BDT}-${TTYPE}.disptmva.root $ODIR/${BDT}-${TTYPE}.training.log
fi
