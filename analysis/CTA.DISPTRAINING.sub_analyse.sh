#!/bin/sh
#
# train TMVA BDTs for DISP
#
# Input parameter
#     - output directory for training files
#     - input evndisp file
#     - recid
#     - scaling
#     - array layout (without telescope combinations)
#
# Example for prod3b:
#
# ./CTA.DISPTRAINING.sub_analyse.sh prod3b-paranal20degq05-NN $CTA_USER_DATA/analysis/AnalysisData/prod3b-paranal20degq05-NN/BDT.TMVAO 0 S.3HB9 $CTA_EVNDISP_AUX_DIR/ParameterFiles/TMVA.BDTDisp.runparameter 99
#
# Parameter file for training can be found here: $CTA_EVNDISP_AUX_DIR/ParameterFiles/TMVA.BDTDisp.runparameter
#
# Removed BDTDispCore (could be simply added)
#
SUBC="condor"
h_cpu="47:29:00"
h_vmem="24000M"
tmpdir_size="1G"

if [ $# -lt 5 ]
then
   echo
   echo "CTA.DISPTRAINING_sub_analyse.sh <data set> <output directory> <recid> <array layout (e.g. S.3HB1)> <TMVA parameters> [scaling] [qsub options (optional)] [job_dir]"
   echo ""
   echo "  <data set>         e.g. cta-ultra3, ISDC3700m, ...  "
   echo "  <output directory> training results will be written to this directory (full path)"
   echo "  <recid>            reconstruction ID according to EVNDISP.reconstruction.parameter"
   echo "  <array layout>     layout name with telescope type ID and scaling (e.g. S.3HB1)"
   echo "  <TMVA parameters>  file name of list of TMVA parameter file"
   echo "  <scaling>          layout scaling (e.g. 5); give 99 to ignore scaling"
   echo
   echo "  (note 1: hardwired telescope types in this script)"
   echo "  (note 2: disp core training switched off)"
   echo
   exit
fi

#########################################
# input parameters
#########################################
DSET=$1
ODIR=$2
RECID=$3
ARRAY=$4
TMVAP=$5
SCALING=999
if [ -n $6 ]
then
    SCALING=$6
fi
TMVAQC=""
if [ -n $8 ]
then
   TMVAQC="$7"
fi
if [ -n $8 ]
then
   QSUBOPT="$8"
fi
QSUBOPT=${QSUBOPT//_X_/ }
QSUBOPT=${QSUBOPT//_M_/-}

#########################################
# TMVA options
TMVA=`cat $TMVAP`
# TMVA quality cuts
QCA=`cat $TMVAQC`

#########################################
# software paths
source ../setSoftwarePaths.sh $DSET
# checking the path for binary
if [ -z $EVNDISPSYS ]
then
    echo "no EVNDISPSYS environmental variable defined"
    exit
fi
EVNDISP="EVNDISP"

#########################################
# output directory for error/output from batch system
# in case you submit a lot of scripts: QLOG=/dev/null
DATE=`date +"%y%m%d"`
QLOG=$CTA_USER_LOG_DIR/$DATE/DISPTRAINING/
SHELLDIR=$CTA_USER_LOG_DIR/$DATE/DISPTRAINING/
if [ -n ${9} ]; then
    QLOG=${9}
    SHELLDIR=${QLOG}
fi
mkdir -p $QLOG
mkdir -p $SHELLDIR

# skeleton script
FSCRIPT="CTA.DISPTRAINING.qsub_analyse"

########################################
# list of telescopes
if [[ $DSET == *"prod3"* ]]
then
    if [[ -e ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod3.teltypes.dat ]]; then
        if [[ $DSET == *"LaPalma"* ]]
        then
            TELTYPELIST=$(grep "*" ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod3.teltypes.dat | grep XSTN | awk '{ $1=""; $2=""; print}')
        else
            TELTYPELIST=$(grep "*" ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod3.teltypes.dat | grep XST | awk '{ $1=""; $2=""; print}')
        fi
    else
        echo "Error: Prod3 teltype file not found"
        exit
    fi
elif [[ $DSET == *"prod4"* ]]
then
    if [[ -e ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod4.teltypes.dat ]]; then
        if [[ $DSET == *"MST"* ]]; then
            TELTYPELIST=$(grep "*" ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod4.teltypes.dat | grep MST | awk '{ $1=""; $2=""; print}')
        else
            TELTYPELIST=$(grep "*" ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod4.teltypes.dat | grep XST | awk '{ $1=""; $2=""; print}')
        fi
    else
        echo "Error: Prod4 teltype file not found"
        exit
    fi
elif [[ $DSET == *"prod5"* ]]
then
    if [[ -e ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod5.teltypes.dat ]]; then
        TELTYPELIST=$(grep "*" ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod5.teltypes.dat | grep XST | awk '{ $1=""; $2=""; print}')
    else
        echo "Error: Prod5 teltype file not found"
        exit
    fi
elif [[ $DSET == *"prod6"* ]]
then
    if [[ -e ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod6.teltypes.dat ]]; then
        TELTYPELIST=$(grep "*" ${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod6.teltypes.dat | grep XST | awk '{ $1=""; $2=""; print}')
    else
        echo "Error: Prod6 teltype file not found"
        exit
    fi
else
    echo "unknown data set $DSET"
    exit
fi

if [[ $TMVAP == *"MLP"* ]]; then
   declare -a MLPLIST=( "MLPDisp" "MLPDispEnergy" "MLPDispError" "MLPDispCore" )
else
   declare -a MLPLIST=( "BDTDisp" "BDTDispEnergy" "BDTDispError" "BDTDispCore" "BDTDispPhi" "BDTDispSign" )
fi

#########################################
#
#########################################
for MLP in "${MLPLIST[@]}"
do
    for MCAZ in 0deg 180deg
    do
      NSTEP=0
      for T in ${TMVA}
      do
        echo $T
        for QC in ${QCA}
        do
            echo $QC

            let "NSTEP = $NSTEP + 1"
            # output directory (match CTA.MSCW_ENERGY.qsub_analyse_MC.sh)
            OFFDIR=${ODIR}.J${NSTEP}
            ####################
            # output directory
            TDIR="${OFFDIR}/${MLP}/${MCAZ}/"
            mkdir -p $TDIR

            for TELTYPE in $TELTYPELIST
            do
                echo
                echo "STARTING ${MLP} TRAINING FOR AZ DIRECTION $MCAZ AND TELESCOPE TYPE $TELTYPE"
                echo "   training options: ${T}"
                echo "    $DSET $ARRAY"
                echo "=========================================================================="

                ####################
                # input file list (based on lists generated by separateDispTrainingEvndispFiles)
                TLIST="$SHELLDIR/EDISP-$DSET-$ARRAY-$SCALING-$MCAZ-$TELTYPE-$MLP-$NSTEP.list"
                cp -f $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/EVNDISP.TRAIN/gamma_cone_${MCAZ}.list ${TLIST}
                cat $CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/EVNDISP.TRAIN/gamma_onSource_${MCAZ}.list >> ${TLIST}
                shuf ${TLIST} -o ${TLIST}
                echo "List of $(wc -l ${TLIST}) input files for training: $TLIST"

                ####################
                # prepare run scripts
                FNAM="$SHELLDIR/EDISP-$ARRAY-$DSET-$SCALING-$MCAZ-$TELTYPE-$MLP-$NSTEP"
                cp $FSCRIPT.sh $FNAM.sh

                  sed -i -e "s|OFILE|$TDIR|" \
                         -e "s|TELTYPE|$TELTYPE|" \
                         -e "s|MLPTYPE|$MLP|" \
                         -e "s|RECONSTRUCTIONID|$RECID|" \
                         -e "s|ILIST|$TLIST|" \
                         -e "s|TTT|$T|" \
                         -e "s|AAA|$ARRAY|" \
                         -e "s|QQQQ|$QC|" \
                         -e "s|DATASET|$DSET|" $FNAM.sh

                  chmod u+x $FNAM.sh
                  echo "shell script " $FNAM.sh

                  # submit the job
                  if [[ $SUBC == *qsub* ]]; then
                      qsub $QSUBOPT -l h_cpu=${h_cpu} -l h_rss=${h_vmem} -V -o $QLOG/ -e $QLOG/ "$FNAM.sh"
                  elif [[ $SUBC == *condor* ]]; then
                      ./condorSubmission.sh "${FNAM}.sh" $h_vmem $tmpdir_size
                  fi
               done
             done
         done
    done
done

echo "shell scripts are written to $SHELLDIR"
echo "batch output and error files are written to $QLOG"

exit
