#!/bin/sh
#
# calculate effective areas and instrument response functions for CTA
#
#
#
##############################################################################

echo
echo "calculating effective areas for CTA: create run scripts"
echo "------------------------------------------------"
echo

source ${EVNDISPSYS}/setObservatory.sh CTA

######################################################################
# input variables
######################################################################
ANAPAR=PPPANAPAR
ARRAY=PPPARRAY
RECID=PPPRECID
PTYPE=PPPVPART
CFIL=PPPCCUT
ODIR=PPPODIR
GFILLING=PPPGMOD
DSET=PPPDSET
MCAZ="PPPMCAZ"

# Choose PARTICLE type from job id
let "PARTID = $SGE_TASK_ID - 1"
declare -a PTYPELIST=("gamma_onSource" "electron_onSource" "proton_onSource" "gamma_cone" "electron" "proton")
if [ $PTYPE = "GAMMA" ]
then
    declare -a PTYPELIST=("gamma_onSource" "gamma_cone")
fi
PART="${PTYPELIST[$PARTID]}"
echo "PROCESSING PARTICLE $PART"

#######################################
# read analysis values from parameter file
if [ ! -e $ANAPAR ]
then
  echo "error: analysis parameter file not found: $ANAPAR" 
  exit
fi
cp -f $ANAPAR $TMPDIR
ANAPARF=`basename $ANAPAR`
ANAPAR="${TMPDIR}/${ANAPARF}"
# check again than runparameter file is available
if [ ! -e $ANAPAR ]
then
  echo "error: analysis parameter file not found in tmp directory: $ANAPAR" 
  exit
fi
echo "reading analysis parameter from $ANAPAR"
cat $ANAPAR

# off-axis binning
BFINEBINNING="FALSE"
if grep -q OFFAXISFINEBINNING $ANAPAR
then
    BFINEBINNING=`grep OFFAXISFINEBINNING $ANAPAR | awk {'print $2'}`
fi
# DL2 filling
DL2FILLING="FALSE"
if grep -q DL2 $ANAPAR
then
   DL2FILLING=`grep DL2 $ANAPAR | awk {'print $2'}`
fi

NIMAGESMIN=`grep NIMAGESMIN $ANAPAR | awk {'print $2'}`
# get telescope type dependent cuts 
NCUTLST=`grep NLST $ANAPAR | awk {'print $2'}`
NCUTMST=`grep NMST $ANAPAR | awk {'print $2'}`
NCUTSST=`grep NSST $ANAPAR | awk {'print $2'}`
NCUTSCMST=`grep NSCMST $ANAPAR | awk {'print $2'}`
if [[ $DSET == *"prod5"* ]]; then
   TELLIST=${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod5.teltypes.dat
elif [[ $DSET == *"prod4"* ]]; then
   TELLIST=${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod4.teltypes.dat
elif [[ $DSET == *"prod3"* ]]; then
   TELLIST=${CTA_EVNDISP_AUX_DIR}/DetectorGeometry/CTA.prod3.teltypes.dat
fi
if [[ -e ${TELLIST} ]]; then
   TELTYPESLST=$(grep "*" ${TELLIST} | grep LST | awk '{ $1=""; $2=""; print}')
   TELTYPESMST=$(grep "*" ${TELLIST} | grep MST | grep -v SCMST | awk '{ $1=""; $2=""; print}')
   TELTYPESSST=$(grep "*" ${TELLIST} | grep SST | awk '{ $1=""; $2=""; print}')
   TELTYPESSCMST=$(grep "*" ${TELLIST} | grep SCMST | awk '{ $1=""; $2=""; print}')
else
  echo "Problem / error? ${TELLIST} teltype file not found"
  exit
fi

for T in LST MST SST SCMST 
do
    NCUT="NCUT${T}"
    if [ -z "${!NCUT}" ]
    then
       declare "NCUT${T}=0"
    fi
    TELTYPES="TELTYPES${T}"
    if [ -z "${!TELTYPES}" ]
    then
       declare "TELTYPES${T}=0"
    fi
    echo "NCUT${T}" "TELTYPES${T}"
done



# get all directories
ANADIR=`grep MSCWSUBDIRECTORY  $ANAPAR | awk {'print $2'}`
TMVACUT=`grep TMVASUBDIR $ANAPAR | awk {'print $2'}`
EFFAREADIR=`grep EFFAREASUBDIR $ANAPAR | awk {'print $2'}`
EFFAREABASEDIR=`grep EFFAREASUBBASEDIR $ANAPAR | awk {'print $2'}`
if [ -z $EFFAREABASEDIR ]
then
   EFFAREABASEDIR=$EFFAREADIR
fi
# see if strict separation of training/testing events if possible
# (mscw files would be in a directory ....EFF)
if [ -e ${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/$ARRAY/${ANADIR}.EFFAREA.MCAZ${MCAZ} ]
then
    ANADIR=${ANADIR}.EFFAREA.MCAZ${MCAZ}
fi

# observation time
OBSTIME=`grep OBSERVINGTIME_H $ANAPAR | awk {'print $2'}`
GETXOFFYOFFAFTERCUTS=`grep GETXOFFYOFFAFTERCUTS $ANAPAR | awk  {'print $2'}`
echo "Input parameters read from $ANAPAR"
echo "  Analysis parameters: $NIMAGESMIN $ANADIR $TMVACUT $EFFAREADIR $OBSTIME"

if [ -z "$ANADIR" ] || [ -z "$NIMAGESMIN" ] || [ -z "$TMVACUT" ] || [ -z "$EFFAREADIR" ] || [ -z "$OBSTIME" ]
then
  echo "error: analysis parameter file not correct: $ANAPAR" 
  echo " one variable missing"
  exit
fi

######################################################################
# directories
######################################################################
echo "data (input) directory"
DDIR=$CTA_USER_DATA_DIR/analysis/AnalysisData/$DSET/$ARRAY/$ANADIR/
echo $DDIR
mkdir -p $DDIR
echo "output data directory"
echo $ODIR
mkdir -p $ODIR

######################################################################
# maximum core distance to a telescope
######################################################################
MAXCDISTANCE="500."
if [ $RECID = "1" ]
then
    MAXCDISTANCE="200."
fi
MAXCDISTANCE="600."
if [ $RECID = "1" ]
then
    MAXCDISTANCE="300."
fi

######################################################################
# off-axis variables:
#
# OFFMEA: off-axis angle used to select BDTs (need to be the same
#                 as in BDT training)
# OFFMIN/OFFMAX: range used for signal cuts
# THETAMIN/THETAMX: range used for background cuts

echo "$PART"
echo
######################################################################
# input files and input parameters
######################################################################
# parameters which are the same for all particle types
# no AZ bins (CTA sims are sorted already on the input side in AZ)
AZBINS="0"
TELTYPECUTS="1"
# data directory
# on source gamma rays
if [ $PART = "gamma_onSource" ]
then
   if [[ ${DSET:0:2} == "GR" ]]
   then
       MSCFILE=$DDIR/gamma*"deg$MCAZ"*"baseline_evndisp"*.mscw.root
   else
       MSCFILE=$DDIR/gamma_onSource."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root
   fi
   OFIL=gamma_onSource."$ARRAY"_ID"$RECID".eff
   OFFMIN=( 0. )
   OFFMAX=( 100000. )
   OFFMEA=( "0.5" )
# NOTE: this is theta2
   THETA2MIN=( -1. )
# using TMVA or angular resolution
   THETA2MAX=( -1. )
   ISOTROPY="0"
   DIRECTIONCUT="2"
fi
# isotropic gamma-rays: analyse in rings in camera distance
if [ $PART = "gamma_cone" ]
then
   if [[ ${DSET:0:2} == "GR" ]]
   then
       MSCFILE=$DDIR/gamma*"deg$MCAZ"*"baseline_cone10_evndisp"*.mscw.root
   else
       MSCFILE=$DDIR/gamma_cone."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root
   fi
   OFIL=gamma_cone."$ARRAY"_ID"$RECID".eff
   # note that these bins are also hardwired in VTableLookupRunParameter::setCTA_MC_offaxisBins
   if [ $BFINEBINNING = "TRUE" ]
   then
       OFFMIN=( 0.0 1.0 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0 5.25 5.5 )
       OFFMAX=( 1.0 2.0 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0 5.25 5.5 5.75 6.0 )
       OFFMEA=( 0.5 1.5 1.5 2.5  2.5 2.5  2.5 3.5  3.5 3.5  3.5 4.5  4.5 4.5  4.5 5.5  5.5 )
   else
       OFFMIN=( 0.0 1.0 2.0 3.0 4.0 5.0 )
       OFFMAX=( 1.0 2.0 3.0 4.0 5.0 6.0 )
       OFFMEA=( 0.5 1.5 2.5 3.5 4.5 5.5 )
   fi
# NOTE: this is theta2
   THETA2MIN=( -1. )
   THETA2MAX=( -1. )
   ISOTROPY="0"
   DIRECTIONCUT="2"
fi
if [ $PART = "electron" ] || [ $PART = "electron_onSource" ]
then
   if [[ ${DSET:0:2} == "GR" ]]
   then
       MSCFILE=$DDIR/electron*"deg$MCAZ"*mscw.root
   else
       MSCFILE=$DDIR/electron."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root
   fi
   OFFMIN=( 0. )
   OFFMAX=( 100000. )
# NOTE: this is theta and not theta2
   if [ $PART = "electron" ]
   then
      OFIL=electron."$ARRAY"_ID"$RECID".eff
       if [ $BFINEBINNING = "TRUE" ]
       then
           THETA2MIN=( 0.0 1.0 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0 5.25 5.5 )
           THETA2MAX=( 1.0 2.0 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0 5.25 5.5 5.75 6.0 )
           OFFMEA=(    0.5 1.5 1.5 2.5  2.5 2.5  2.5 3.5  3.5 3.5  3.5 4.5  4.5 4.5  4.5 5.5  5.5 )
      else
          THETA2MIN=( 0.0 1.0 2.0 3.0 4.0 5.0 )
          THETA2MAX=( 1.0 2.0 3.0 4.0 5.0 6.0 )
          OFFMEA=( 0.5 1.5 2.5 3.5 4.5 5.5 )
      fi
   else
      OFIL=electron_onSource."$ARRAY"_ID"$RECID".eff
      THETA2MIN=( 0. )
      THETA2MAX=( 1. )
      OFFMEA=( 0.5 )
   fi   
   ISOTROPY="1"
   DIRECTIONCUT="0"
fi 
if [ $PART = "proton" ] || [ $PART = "proton_onSource" ]
then
   if [[ ${DSET:0:2} == "GR" ]]
   then
       MSCFILE=$DDIR/proton*"deg$MCAZ"*mscw.root
   else
       MSCFILE=$DDIR/proton*."$ARRAY"_ID"$RECID$MCAZ"*.mscw.root
   fi    
   if [ $ARRAY = "V5" ]
   then
      MSCFILE=$DDIR/proton."$ARRAY"_ID"$RECID$MCAZ".mscw.root
   fi
   OFIL=proton."$ARRAY"_ID"$RECID".eff
   OFFMIN=( 0. )
   OFFMAX=( 100000. )
# NOTE: this is theta and not theta2
   if [ $PART = "proton" ] 
   then
      OFIL=proton."$ARRAY"_ID"$RECID".eff
       if [ $BFINEBINNING = "TRUE" ]
       then
           THETA2MIN=( 0.0 1.0 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0 5.25 5.5 )
           THETA2MAX=( 1.0 2.0 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0 5.25 5.5 5.75 6.0 )
           OFFMEA=(    0.5 1.5 1.5 2.5  2.5 2.5  2.5 3.5  3.5 3.5  3.5 4.5  4.5 4.5  4.5 5.5  5.5 )
      else
          THETA2MIN=( 0.0 1.0 2.0 3.0 4.0 5.0 )
          THETA2MAX=( 1.0 2.0 3.0 4.0 5.0 6.0 )
          OFFMEA=( 0.5 1.5 2.5 3.5 4.5 5.5 )
      fi
   else
      OFIL=proton_onSource."$ARRAY"_ID"$RECID".eff
      THETA2MIN=( 0. )
      # full system / LST only with smaller FOV
      if [ $RECID = "0" ] || [ $RECID = "1" ]
      then
          THETA2MAX=( 1. )
      # MST/SST system allow for larger FOV
      else
          THETA2MAX=( 2. )
      fi
      OFFMEA=( 0.5 )
   fi
   ISOTROPY="1"
   DIRECTIONCUT="0"
fi
NOFF=${#OFFMIN[@]}
NTH2=${#THETA2MIN[@]}
echo "Number of offaxis bins $NOFF $NTH2 $BFINEBINNING"
######################################################################

###############################################################################
# loop over all off-axis bins
for ((i=0; i < $NOFF; i++))
do
   iMIN=${OFFMIN[$i]}
   iMAX=${OFFMAX[$i]}
# loop over all theta2 cuts
   for ((j=0; j < $NTH2; j++))
   do
     jMIN=${THETA2MIN[$j]}
     jMAX=${THETA2MAX[$j]}

###############################################################################
# theta2 cut of protons and electron should match the rings from the isotropic gammas
      if [ $PART = "proton" ] || [ $PART = "proton_onSource" ] || [ $PART = "electron" ] || [ $PART = "electron_onSource" ]
      then
         jMIN=$(echo "$jMIN*$jMIN" | bc -l )
         jMAX=$(echo "$jMAX*$jMAX" | bc -l )
      fi

###############################################################################
     # run particle rate file calculator for BDT
     if [[ $ODIR == *"BDT"* ]]
     then
         echo "RUNNING PARTILE RATE DETERMINATION"
         AXDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/EffectiveAreas/$EFFAREABASEDIR/AngularResolution/"
         QCDIR="${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/EffectiveAreas/$EFFAREABASEDIR/QualityCuts001CU/"
         echo "ANGRESDIR ${AXDIR}"
         echo "QCDIR ${QCDIR}"
         LLOG=$TMPDIR/ParticleNumbers.$ARRAY.$RECID.log
         rm -f $LLOG

         # onSource
         if [[ $PART == *"onSource"* ]]; then
             echo "PPPP $ARRAY onSource $RECID $QCDIR $TMPDIR $AXDIR"
             ${EVNDISPSYS}/bin/writeParticleRateFilesFromEffectiveAreas $ARRAY onSource $RECID $QCDIR $TMPDIR $AXDIR > $LLOG
         else
             # cone
             # off-axis fine binning
             if [ $BFINEBINNING = "TRUE" ]
             then
                 ${EVNDISPSYS}/bin/writeParticleRateFilesFromEffectiveAreas  $ARRAY coneFB $RECID $QCDIR $TMPDIR $AXDIR > $LLOG
             else
             # off-axis std binning
                 echo "PPP $ARRAY cone $RECID $QCDIR $TMPDIR $AXDIR"
                 ${EVNDISPSYS}/bin/writeParticleRateFilesFromEffectiveAreas  $ARRAY cone $RECID $QCDIR $TMPDIR $AXDIR > $LLOG
             fi
         fi
         cat $LLOG
    fi
###############################################################################
# create cut file
      iCBFILE=`basename $CFIL`      
      if [ $PART = "gamma_onSource" ] || [ $PART = "gamma_cone" ] 
      then
          CFILP="${CFIL}.gamma.dat"
      else
          CFILP="${CFIL}.CRbck.dat"
      fi
      iCFIL=$TMPDIR/ANASUM.GammaHadron-$DSET-$PART-$i-$j-MCAZ${MCAZ}.$iCBFILE.dat

      if [ ! -e $CFILP ]
      then
        echo "ERROR: cut file does not exist:"
        echo $CFILP
        exit
      fi
      cp -f $CFILP $iCFIL

# wobble offset
      if [ $PART = "gamma_onSource" ] || [ $PART = "gamma_cone" ] 
      then
         WOBBLEOFFSET=${OFFMEA[$i]}
      else
         WOBBLEOFFSET=${OFFMEA[$j]}
      fi
# angular resolution file
      if [ $PART = "gamma_onSource" ] 
      then
         ANGRESFILE=${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/EffectiveAreas/$EFFAREABASEDIR/AngularResolution/gamma_onSource."$ARRAY"_ID"$RECID".eff-0.root
      else
         ANGRESFILE=${CTA_USER_DATA_DIR}/analysis/AnalysisData/$DSET/EffectiveAreas/$EFFAREABASEDIR/AngularResolution/gamma_cone."$ARRAY"_ID"$RECID".eff-$i.root
      fi
# particle number file
      if [ $PART = "gamma_onSource" ] || [ $PART = "electron_onSource" ] || [ $PART = "proton_onSource" ]
      then
         PNF=$TMPDIR/ParticleNumbers."$ARRAY".00.root
      elif [ $PART = "gamma_cone" ]
      then
         PNF=$TMPDIR/ParticleNumbers."$ARRAY".$i.root
      else
         PNF=$TMPDIR/ParticleNumbers."$ARRAY".$j.root
      fi

      sed -i -e "s|OFFMIN|$iMIN|" \
             -e "s|OFFMAX|$iMAX|" \
             -e "s|THETA2MIN|$jMIN|" \
             -e "s|THETA2MAX|$jMAX|" \
             -e "s|DIRECTIONCUT|$DIRECTIONCUT|" \
             -e "s|SUBARRAY|$ARRAY|" \
             -e "s|MINIMAGES|$NIMAGESMIN|" \
             -e "s|NTELTYPELST|$NCUTLST|" \
             -e "s|NTELTYPEMST|$NCUTMST|" \
             -e "s|NTELTYPESST|$NCUTSST|" \
             -e "s|NTELTYPESCMST|$NCUTSCMST|" \
             -e "s|TELTYPESLST|$TELTYPESLST|" \
             -e "s|TELTYPESMST|$TELTYPESMST|" \
             -e "s|TELTYPESSST|$TELTYPESSST|" \
             -e "s|TELTYPESSCMST|$TELTYPESSCMST|" \
             -e "s|WOBBLEOFFSET|$WOBBLEOFFSET|" \
             -e "s|TMVACUTDIR|$TMVACUT|" \
             -e "s|DATASET|$DSET|" \
             -e "s|ANGRESFILE|$ANGRESFILE|" \
             -e "s|PARTICLENUMBERFILE|$PNF|" \
             -e "s|MAXCOREDISTANCE|$MAXCDISTANCE|" \
             -e "s|OBSERVINGTIME_H|$OBSTIME|" $iCFIL

      echo $iCFIL

###############################################################################
# create run list
      MSCF=$TMPDIR/effectiveArea-CTA-$DSET-$PART-$i-$j.$ARRAY-MCAZ${MCAZ}-${ANADIR}.dat
      rm -f $MSCF
      echo "effective area data file for $PART $i $j" > $MSCF
###############################################################################
# general run parameters
###############################################################################
# filling mode
###############################################################################
# fill IRFs and effective areas
      if [ $PART = "gamma_onSource" ] || [ $PART = "gamma_cone" ]
      then
# filling mode 0: fill and use angular resolution for energy dependent theta2 cuts
         echo "* FILLINGMODE $GFILLING" >> $MSCF
      else
# background: use fixed theta2 cut
         echo "* FILLINGMODE 3" >> $MSCF
      fi
# fill IRFs only
      echo "* ENERGYRECONSTRUCTIONMETHOD 1" >> $MSCF
      echo "* ENERGYAXISBINS 60" >> $MSCF
      echo "* ENERGYRECONSTRUCTIONQUALITY 0" >> $MSCF
# one azimuth bin only
      echo "* AZIMUTHBINS $AZBINS" >> $MSCF
      echo "* ISOTROPICARRIVALDIRECTIONS $ISOTROPY" >> $MSCF
      echo "* TELESCOPETYPECUTS $TELTYPECUTS" >> $MSCF
# do fill analysis (a 1 would mean that MC histograms would be filled only)
      echo "* FILLMONTECARLOHISTOS 0" >> $MSCF
# spectral index & CR spectra
      if [ $PART = "proton" ] || [ $PART = "proton_onSource" ]
      then
         echo "* ENERGYSPECTRUMINDEX  1 2.5 0.1" >> $MSCF
         echo "* ESPECTRUM_FOR_WEIGHTING $CTA_EVNDISP_AUX_DIR/AstroData/TeV_data/EnergySpectrum_literatureValues_CR.dat 0" >> $MSCF
         if  [ $GETXOFFYOFFAFTERCUTS = "yes" ]
         then	
             echo "* GETXOFFYOFFAFTERCUTS 1" >> $MSCF
         fi    

      fi
      if [ $PART = "electron" ] || [ $PART = "electron_onSource" ]
      then
         echo "* ENERGYSPECTRUMINDEX  1 2.5 0.1" >> $MSCF
         echo "* ESPECTRUM_FOR_WEIGHTING $CTA_EVNDISP_AUX_DIR/AstroData/TeV_data/EnergySpectrum_literatureValues_CR.dat 8" >> $MSCF
         if  [ $GETXOFFYOFFAFTERCUTS = "yes" ]
         then
         echo "* GETXOFFYOFFAFTERCUTS 1" >> $MSCF
         fi
      fi
      if [ $PART = "gamma_onSource" ] || [ $PART = "gamma_cone" ]
      then
         echo "* ENERGYSPECTRUMINDEX  1 2.5 0.1" >> $MSCF
         echo "* ESPECTRUM_FOR_WEIGHTING $CTA_EVNDISP_AUX_DIR/AstroData/TeV_data/EnergySpectrum_literatureValues_CrabNebula.dat 5" >> $MSCF
      fi
      echo "* CUTFILE $iCFIL" >> $MSCF
      echo "* SIMULATIONFILE_DATA $MSCFILE" >> $MSCF
      # to write full data trees (DL2)
      # (note: very large output files!)
      if [[ $DL2FILLING = "TRUE" ]]; then
          echo "* WRITEEVENTDATATREE 1" >> $MSCF
      fi

# output file
      if [ $PART = "gamma_onSource" ] || [ $PART = "gamma_cone" ]
      then
         OFIX=$TMPDIR/$OFIL-$i
         OLOG=$ODIR/$OFIL-$i
      else
         OFIX=$TMPDIR/$OFIL-$j
         OLOG=$ODIR/$OFIL-$j
      fi

      echo
      echo "preparing new analysis run"
      echo "--------------------------"
      echo
      echo "gamma/hadron separation file"
      echo $iCFIL
      echo $PNF

      minimumsize=300
      #### temp
      # only run when analysis needs to be repeated
      # require file size of at least 1 M
      #if [[ -e $OLOG.root ]]; then
      #    DS=$(du -k $OLOG.root | cut -f 1)
      #    if [[ ${DS} -ge $minimumsize ]]; then
      #        continue
      #    fi
      #fi
      #### (end) temp

  ##############################
  # run effective area code
      ${EVNDISPSYS}/bin/makeEffectiveArea $MSCF $OFIX.root > $OLOG.log

      # cross check if run was successfull
      # (expect simply > 800k)
      DS=$(du -k $OFIX.root | cut -f 1)
      if [[ ${DS} -le $minimumsize ]]; then
          touch $OLOG.SMALLFILE
          mv -v $OFIX.root ${ODIR}/
          continue
      fi

  ##############################
  #  cleanup
  # (reduce number of files)
      if [[ -e $OFIX.root ]] && [[ -e $MSCF ]]; then
          ${EVNDISPSYS}/bin/logFile effAreaParameters $OFIX.root $MSCF
          rm -f $MSCF
      fi

      if [[ -e $OFIX.root ]] && [[ -e $iCFIL ]]; then
          ${EVNDISPSYS}/bin/logFile effAreaCuts $OFIX.root $iCFIL
          rm -f $iCFIL
      fi

      if [[ -e $OFIX.root ]] && [[ -e $OLOG.log ]]; then
          ${EVNDISPSYS}/bin/logFile effAreaLog $OFIX.root $OLOG.log
          rm -f $OLOG.log
      fi

      if [[ -e $TMPDIR/ParticleNumbers.$ARRAY.$RECID.log ]]; then
         ${EVNDISPSYS}/bin/logFile writeRateLog $OFIX.root $TMPDIR/ParticleNumbers.$ARRAY.$RECID.log
      fi
      # final results file
      mv -v $OFIX.root ${ODIR}/
   done
done

exit


exit
