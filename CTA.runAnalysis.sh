#!/bin/sh
#
# analysis submission for production 3b analysis 
#
# this script is optimized for the DESY analysis
#
##############################################


if [ $# -lt 2 ] 
then
   echo "
   ./CTA.runbAnalysis.sh <S/S40deg> <run mode> [recid] \\\\
                [min number of LSTs] [min number of MSTs] [min number of SSTs] [min number of SCMSTs]
   
    Prod3b analysis:
         prod3b-S20deg / prod3b-S40deg / prod3b-S60deg
         prod3b-N20deg / prod3b-N40deg / prod3b-N60deg
    Prod4 analysis:
         prod4-S20deg-MST
    Prod5 analysis:
         prod5-N , prod5-N-s01-F, prod5-N-s01-N
         prod5-South
         prod5-South-40deg
         prod5-South-60deg
         add 'moon' for NSB5x data sets
   
    possible run modes are EVNDISP MAKETABLES DISPBDT/DISPMLP ANATABLES PREPARETMVA TRAIN ANGRES QC CUTS PHYS 
   
    [recids]: 0 = all telescopes (default), 1 = LSTs, 2 = MSTs, 3 = SSTs, 4 = MSTs+SSTs, 5 = LSTs+MSTs
    [XST multiplicities]: default = 2
   "
   
   exit
fi

# site
P2="$1"
# run mode
RUN="$2"
# reconstruction IDs
[[ "$3" ]] && RECID=$3 || RECID="0"
# number of telescopes
[[ "$4" ]] && LST=$4 || LST="2"
[[ "$5" ]] && MST=$5 || MST="2"
[[ "$6" ]] && SST=$6 || SST="2"
[[ "$7" ]] && SCMST=$7 || SCMST="2"
echo "Telescope multiplicities: LST ${LST} MST ${MST} SST ${SST} SCMST ${SCMST}"

#####################################
# qsub options (priorities)
#   _M_ = -; _X_ = " "
QSUBOPT="_M_P_X_cta_high_X__M_js_X_9"

#####################################
# output directory for script parameter files
PDIR="$CTA_USER_LOG_DIR/tempRunParameterDir/"
mkdir -p "$PDIR"

#####################################
# analysis dates and table dates
TMVAVERSION="V3"
EFFVERSION="V3"

# dates
# (will be overwritten later)
TDATE="g20200817"
ANADATE="${TDATE}"
TMVADATE="${TDATE}"
EFFDATE="${TDATE}"

# off-axis binnning (default=FALSE)
BFINEBINNING="FALSE"
if [ $BFINEBINNING = "TRUE" ]
then
   EFFDATE=${EFFDATE}FB
fi

#####################################
# shower directions
#
# _180deg = south
# _0deg = north
# (note that not all steps are executed for
#  the average AZ bin)
MCAZ=( "" "_180deg" "_0deg" )

##########################################################
# PROD3b Analysis
EDM="u05b-LL"
if [[ $P2 == "prod3b-S20deg" ]]
then
   SITE="prod3b-paranal20deg"
   ARRAY="subArray.prod3b.South.list"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-S20degSV1" ]]
then
   SITE="prod3b-paranal20deg"
   ARRAY="subArray.prod3b.South.list_SV1.list"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-S20degSV2" ]]
then
   SITE="prod3b-paranal20deg"
   ARRAY="subArray.prod3b.South.list_SV2.list"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-S20degSVN" ]]
then
   SITE="prod3b-paranal20deg"
   ARRAY="subArray.prod3b.South.list_SVN.list"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-S40deg" ]]
then
   SITE="prod3b-paranal40deg"
   ARRAY="subArray.prod3b.South.list"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-S60deg" ]]
then
   SITE="prod3b-paranal60deg"
   ARRAY="subArray.prod3b.South.list"
   ARRAYDIR="prod3b"
# NORTH
elif [[ $P2 == "prod3b-N20deg" ]]
then
   SITE="prod3b-LaPalma-20deg"
   SITE="prod3b-LaPalma-20deg-NSB1x"
   ARRAY="subArray.prod3b.North.NSB1x.list"
   EDM="-sq2-LL"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-N40deg" ]]
then
   SITE="prod3b-LaPalma-40deg"
   ARRAY="subArray.prod3b.North.list"
   ARRAYDIR="prod3b"
elif [[ $P2 == "prod3b-S20deg-SCT" ]]
then
   SITE="prod3b-paranal20deg_SCT"
   ARRAY="subArray.prod3b.South-SCT.list"
   ARRAYDIR="prod3b"
   EDM="-sq09-LL"
elif [[ $P2 == "prod3b-S20deg-SCTlin" ]]
then
   SITE="prod3b-paranal20deg_SCTlin"
   ARRAY="subArray.prod3b.South-SCT.list"
   ARRAYDIR="prod3b"
   EDM="-sq09-LL"
###############################################################
###############################################################
# PROD4 Analysis
elif [[ $P2 == "prod4-S20deg-MST" ]]
then
   SITE="prod4-MST-paranal-20deg-mst-f"
   ARRAY=( "subArray.prod4-MST-baseline.list" )
   ARRAYDIR="prod4"
elif [[ $P2 == "prod4-S20deg-SST" ]]
then
# for other prod4(b) SST data sets:
# - set file lists correctly
# - prepare and install software (each SST type is a DSET)
   SITE="prod4b-SST-paranal20deg"
   EDM="-sq08-LL"
   # non-ASTRI
   ARRAY=( "subArray.prod4-SST.list" )
   # ASTRI telescopes
   ARRAY=( "subArray.prod4-SST-A.list" )
   ARRAYDIR="prod4"
   TDATE="g20201021"
   ANADATE="${TDATE}"
   TMVADATE="${ANADATE}"
   EFFDATE="${TMVADATE}"
###############################################################
###############################################################
# PROD5 Analysis
# prod5-N
# prod5-N-moon (NSB5x)
elif [[ $P2 == "prod5-N"* ]]
then
   if [[ $P2 == *"moon"* ]]; then
       SITE="prod5-LaPalma-20deg-NSB5x"
   else
       SITE="prod5-LaPalma-20deg"
   fi
   EDM="-sq08-LL"
   ARRAY=( "subArray.prod5.North-MSTF-Arrays.list" )
   ARRAY=( "subArray.prod5.North-XST.list" )
   # prod5-prod5b comparision
   ARRAY=( "subArray.prod5-prod5b.North.list" )
   if [[ $P2 == *"Hyper"* ]]; then
       ARRAY=( "subArray.prod5.North-Hyper.list" )
   fi
   if [[ $P2 == *"LST"* ]]; then
       ARRAY=( "subArray.prod5.North-LST.list" )
   fi
   ARRAYDIR="prod5"
   TDATE="g20201021"
   ANADATE="${TDATE}"
   TMVADATE="${ANADATE}"
   EFFDATE="${TMVADATE}"
####################################
# PROD5 Analysis
# prod5b-N (including additional telescopes)
elif [[ $P2 == "prod5b-N"* ]]
then
   SITE="prod5b-LaPalma-20deg"
   EDM="-sq08-LL"
   ARRAY=( "subArray.prod5b.North.list" )
   ARRAY=( "subArray.prod5-prod5b.North.list" )
   if [[ $P2 == *"LST"* ]]; then
       ARRAY=( "subArray.prod5.North-LST.list" )
   fi
   if [[ $P2 == *"XST"* ]]; then
       ARRAY=( "subArray.prod5.North-XST.list" )
   fi
   ARRAYDIR="prod5"
   TDATE="g20201203"
   ANADATE="${TDATE}"
   TMVADATE="${ANADATE}"
   EFFDATE="${ANADATE}"
####################################
# prod5 - Paranal
# prod5-S
# prod5-S-moon (NSB5x)
elif [[ $P2 == "prod5-S"* ]]
then
   if [[ $P2 == *"40deg"* ]]; then
       SITE="prod5-Paranal-40deg"
   elif [[ $P2 == *"60deg"* ]]; then
       SITE="prod5-Paranal-60deg"
   else
       SITE="prod5-Paranal-20deg"
   fi
   if [[ $P2 == *"moon"* ]]; then
       SITE="${SITE}-NSB5x"
   fi
   EDM="-sq10-LL"
   ARRAY=( "subArray.prod5.South-Opt-13MSTsN0SSTs-MX.list" )
   if [[ $P2 == *"sub"* ]]; then
       ARRAY=( "subArray.prod5.South-Opt-SubArray.list" )
   fi
   if [[ $P2 == *"moon"* ]]; then
      ARRAY=( "subArray.prod5.South-Opt-Top4.list" )
   fi
   if [[ $P2 == *"Hyper"* ]]; then
       ARRAY=( "subArray.prod5.South-Hyper.list" )
   fi
   if [[ $P2 == *"LST"* ]]; then
       ARRAY=( "subArray.prod5.South-LST.list" )
   fi
   if [[ $P2 == *"SST"* ]]; then
       ARRAY=( "subArray.prod5.South-SST.list" )
   fi
   if [[ $P2 == *"1ST"* ]]; then
       ARRAY=( "subArray.prod5.South-1ST.list" )
   fi
   if [[ $P2 == *"SV0"* ]]; then
      EDM="-1MST-LL"
      ARRAY=( "subArray.prod5.South-SV0.list" )
   fi
   ARRAYDIR="prod5"
   TDATE="g20210921"
   ANADATE="${TDATE}"
   TMVADATE="${ANADATE}"
   EFFDATE="${ANADATE}"
else
   echo "error: unknown site; allowed are N or S/S40deg/S60deg"
   echo "$P2"
   exit
fi
# should be either onSource or cone (default is cone)
OFFAXIS="cone"

#####################################
# particle types
PARTICLE=( "gamma_cone" "electron" "proton" "gamma_onSource" )

#####################################
# cut on number of images
# smallest number of all telescope type dependent
# multiplicity requirements
NIMAGESMIN=$((LST<MST ? LST : MST))
NIMAGESMIN=$((SST<NIMAGESMIN ? SST : NIMAGESMIN))
NIMAGESMIN=$((SCMST<NIMAGESMIN ? SCMST : NIMAGESMIN))

#####################################
# observing time [h]
# (note that all steps except CUTS and PHYS are done only for 50h)
OBSTIME=( "50h" "5h" "30m" "10m" "10h" "20h" "100h" "500h" "5m" "1m" "2h" )
OBSTIME=( "50h" "5h" "30m" "100s" )
OBSTIME=( "50h" "30m" )

echo "$RUN" "$SITE"

echo
echo "======================================================================================"
echo "SITE: ${SITE} ${EDM}"
echo "RUN: $RUN"

##########################################
# run eventdisplay
if [[ $RUN == "EVNDISP" ]]
then
# loop over all particle types
  for ((i = 0; i < ${#PARTICLE[@]}; i++ ))
  do
          N=${PARTICLE[$i]}

          LIST=${CTA_USER_DATA_DIR}/analysis/AnalysisData/FileList_${ARRAYDIR}/${SITE}/${N}.list

          echo "READING SIMTEL FILE LIST $LIST"
          if [[ ! -e ${LIST} ]]; then
             echo "error, file list not found: ${LIST}"
             exit
          fi

          cd ./analysis/
          ./CTA.EVNDISP.sub_convert_and_analyse_MC_VDST_ArrayJob.sh ../${ARRAYDIR}/${ARRAY} ${LIST} $N ${SITE}${EDM} 0 $i $QSUBOPT $TRG
          cd ../
   done
   continue
fi
##########################################
# for the following: duplicate the array list adding the scaling to array names
if [[ ! -e ${ARRAYDIR}/$ARRAY ]]; then
   echo "Error: array file not found: ${ARRAYDIR}/$ARRAY"
   exit
fi
NXARRAY=$(cat ${ARRAYDIR}/$ARRAY)
NFILARRAY=$PDIR/temp.$ARRAY.list
rm -f "$NFILARRAY"
touch "$NFILARRAY"
for A in $NXARRAY
do
     echo ${A} >> "$NFILARRAY"
done
##########################################
# dispBDT training
if [[ $RUN == "DISP"* ]]
then
    if [[ $RUN == "DISPMLP" ]]; then
        BDTDIR="MLPdisp."
        RUNPAR="${CTA_EVNDISP_AUX_DIR}/ParameterFiles/TMVA.MLPDisp.runparameter"
    else
        BDTDIR="BDTdisp."
        RUNPAR="${CTA_EVNDISP_AUX_DIR}/ParameterFiles/TMVA.BDTDisp.runparameter"
    fi
    QCPAR="${CTA_EVNDISP_AUX_DIR}/ParameterFiles/TMVA.BDTDispQualityCuts.runparameter"
    DDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${SITE}${EDM}/"
    for A in $NXARRAY
    do
        cd ./analysis/
        ./CTA.DISPTRAINING.sub_analyse.sh ${SITE}${EDM} $DDIR/DISPBDT/${BDTDIR}${A} 0 $A $RUNPAR 99 $QCPAR $QSUBOPT
        cd ../
    done
    exit
fi
##########################################
# loop over all reconstruction IDs 
# (telescope type dependent subarrays)
for ID in $RECID
do
   # directory where all mscw output files are written to
   MSCWSUBDIRECTORY="Analysis-ID$ID-${ANADATE}"
# loop over all shower directions 
# (i.e. North and South)
    for ((a = 0; a < ${#MCAZ[@]}; a++ ))
    do
          AZ=${MCAZ[$a]}
          if [ "$AZ" ] 
          then
##########################################
# make (fill) tables
              TABLE="tables_CTA-${SITE}${EDM}-ID0${AZ}-$TDATE"
              if [[ $RUN == "MAKETABLES" ]]
              then
                      echo "Filling table $TABLE with mintel option ${NIMAGESMIN}"
                      cd ./analysis/
                      ./CTA.MSCW_ENERGY.sub_make_tables.sh $TABLE $ID "$NFILARRAY" $OFFAXIS ${SITE}${EDM} ${AZ} ${NIMAGESMIN} $QSUBOPT
                      cd ../
                      continue
##########################################
# analyse with lookup tables
               elif [[ $RUN == "ANATABLES" ]]
               then
                      echo "Analysing files with mintel option ${NIMAGESMIN}"
                      echo "    using table $TABLE"
                      cd ./analysis/
                      ./CTA.MSCW_ENERGY.sub_analyse_MC.sh $TABLE $ID "$NFILARRAY" ${SITE}${EDM} ${MSCWSUBDIRECTORY} $OFFAXIS ${AZ} ${NIMAGESMIN} $QSUBOPT
                      cd ../
                      continue
                fi
           fi
    done
        if [[ $RUN == "MAKETABLES" ]] || [[ $RUN == "ANATABLES" ]]
        then
               continue
        fi
##########################################
# loop over all observation times
        for ((o = 0; o < ${#OBSTIME[@]}; o++ ))
            do
                   OOTIME=${OBSTIME[$o]}

                   # Only the last two steps are run for all observation times
                   if [[ ${RUN} != "CUTS" ]] && [[ ${OOTIME} != "50h" ]]; then
                      continue
                   fi
                   if [[ ${RUN} != "PHYS" ]] && [[ ${OOTIME} != "50h" ]]; then
                      continue
                   fi

##########################################
# loop over all shower directions 
# (i.e. North and South)
            for ((a = 0; a < ${#MCAZ[@]}; a++ ))
            do
                  AZ=${MCAZ[$a]}
# fill a run parameter file
                  ETYPF=NIM${NIMAGESMIN}LST${LST}MST${MST}SST${SST}SCMST${SCMST}
                  TMVATYPF=$ETYPF
                  # paranal mva are named differently
                  if [[ ${SITE} == *"paranal"* ]] && [[ ${SITE} != *"SCT"* ]]
                  then
                      TMVATYPF=NIM${NIMAGESMIN}LST${LST}MST${MST}SST${SST}
                  fi
                  PARA="$PDIR/scriptsInput.${ID}${ETYPF}${AZ}.${SITE}${AZ}${OOTIME}.runparameter"
                  rm -f "$PARA"
                  touch "$PARA"
                  echo "WRITING PARAMETERFILE $PARA"
                  EFFDIR=EffectiveArea-"$OOTIME"-ID$ID$AZ-$ETYPF-$EFFDATE-$EFFVERSION
                  EFFFULLDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/${SITE}${EDM}/EffectiveAreas/${EFFDIR}/"
                  echo "MSCWSUBDIRECTORY ${MSCWSUBDIRECTORY}" >> "$PARA"
                  echo "TMVASUBDIR BDT-${TMVAVERSION}-ID$ID$AZ-$TMVATYPF-$TMVADATE" >> "$PARA"
                  echo "EFFAREASUBDIR ${EFFDIR}" >> "$PARA"
                  EFFBDIR=EffectiveArea-50h-ID$ID$AZ-$ETYPF-$EFFDATE-$EFFVERSION
                  echo "EFFAREASUBBASEDIR $EFFBDIR" >> "$PARA"
                  echo "RECID $ID" >> "$PARA"
                  echo "NIMAGESMIN $NIMAGESMIN" >> "$PARA"
                  echo "NLST ${LST}" >> "$PARA"
                  echo "NMST ${MST}" >> "$PARA"
                  echo "NSST ${SST}" >> "$PARA"
                  echo "NSCMST ${SCMST}" >> "$PARA"
                  echo "OBSERVINGTIME_H $OOTIME" >> "$PARA"
                  echo "GETXOFFYOFFAFTERCUTS yes" >> "$PARA"
                  echo "OFFAXISFINEBINNING $BFINEBINNING" >> "$PARA"
                  if [[ ${RUN} == "CUTS" ]] && [[ ${OOTIME} == "50h" ]]; then
                     # echo "DL2FILLING DL2" >> "$PARA"
                     echo "DL2FILLING FALSE" >> "$PARA"
                  else
                     echo "DL2FILLING FALSE" >> "$PARA"
                  fi

                  cd ./analysis/
##########################################
# prepare train BDTs   
                  if [[ $RUN == "PREPARETMVA" ]] 
                  then
                     if [ ${o} -eq 0 ] && [[ ! -z ${AZ} ]]
                     then
                         ./CTA.prepareTMVA.sub_train.sh "$NFILARRAY" $OFFAXIS ${SITE}${EDM} "$PARA" $QSUBOPT $AZ
                  fi
##########################################
# train BDTs   
# (note: BDT training does not need to be done for all observing periods)
                  elif [[ $RUN == "TRAIN" ]] || [[ $RUN == "TMVA" ]]
                  then
                     if [ ${o} -eq 0 ] && [[ ! -z ${AZ} ]]
                     then
                         ./CTA.TMVA.sub_train.sh "$NFILARRAY" $OFFAXIS ${SITE}${EDM} "$PARA" $QSUBOPT $AZ
                  fi
##########################################
# IRFs: angular resolution
                  elif [[ $RUN == "ANGRES" ]]
                  then
                    if [[ ! -z ${AZ} ]]; then
                        ./CTA.EFFAREA.sub_analyse_list.sh "$NFILARRAY" ANASUM.GammaHadron.TMVAFixedSignal "$PARA" AngularResolution ${SITE}${EDM} 2 $QSUBOPT $AZ
                    fi
##########################################
# IRFs: effective areas after quality cuts
                  elif [[ $RUN == "QC" ]]
                  then
                    if [[ ! -z ${AZ} ]]; then
                        ./CTA.EFFAREA.sub_analyse_list.sh "$NFILARRAY" ANASUM.GammaHadron.QC "$PARA" QualityCuts001CU ${SITE}${EDM} 3 $QSUBOPT $AZ
                     fi
##########################################
# IRFs: effective areas after gamma/hadron cuts
                  elif [[ $RUN == "CUTS" ]]
                  then
                    # large multiplicity runs use 80% max signal efficiency (best resolution)
                    if [[ "${MST}" -ge "4" ]]
                    then
                        ./CTA.EFFAREA.sub_analyse_list.sh "$NFILARRAY" ANASUM.GammaHadron.TMVA "$PARA" BDT."$OOTIME"-${EFFVERSION}.$EFFDATE ${SITE}${EDM} 0 $QSUBOPT $AZ
                    # low multiplicity runs use 95% max signal efficiency (lower requirements on resolution)
                    else
                        ./CTA.EFFAREA.sub_analyse_list.sh "$NFILARRAY" ANASUM.GammaHadron95p.TMVA "$PARA" BDT."$OOTIME"-${EFFVERSION}.$EFFDATE ${SITE}${EDM} 0 $QSUBOPT $AZ
                    fi
##########################################
# CTA WP Phys files
                  elif [[ $RUN == "PHYS" ]]
                  then
                     if [[ $OFFAXIS == "cone" ]]
                     then
                        ./CTA.WPPhysWriter.sub.sh "$NFILARRAY" ${EFFFULLDIR}/BDT."$OOTIME"-${EFFVERSION}.$EFFDATE \
                        $OOTIME DESY.$EFFDATE.${EFFVERSION}.ID$ID$AZ$ETYPF.${SITE}${EDM} 1 $ID ${SITE}${EDM} $BFINEBINNING $EFFDATE $QSUBOPT
                     else
                        ./CTA.WPPhysWriter.sub.sh "$NFILARRAY" ${EFFFULLDIR}/BDT."$OOTIME"-${EFFVERSION}.$EFFDATE \
                        $OOTIME DESY.$EFFDATE.${EFFVERSION}.ID$ID$AZ$ETYPF.${SITE}${EDM} 0 $ID ${SITE}${EDM} $BFINEBINNING $EFFDATE $QSUBOPT
                 fi
# unknown run set
                 elif [[ $RUN != "EVNDISP" ]]
                 then
                      echo "Unknown run set: $RUN"
                      exit
                fi
                cd ../
         done
     done
   done
   echo 
   echo "(end of script)"
