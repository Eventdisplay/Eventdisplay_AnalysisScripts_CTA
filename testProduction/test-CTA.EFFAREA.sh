#!/bin/sh
#
# test EFFAREA results
#
# 2>| /dev/null


# disp training types
if [ $# -lt 4 ]
then
echo "
./test-CTA.EFFAREA.sh <data set> <list of layouts> <recid> <MSCWTEST>

test results of effective area filling

"
exit
fi

##########################################################
# hardwired values
# analysis date
ANADATE="g20210921"
# effarea dates
EFFDATE="g20210921"
# observation time
OBSTIME="30m"
OBSTIME="50h"
# Number of off-axis bins
NWBINS=6
# (end of) hardwired values
##########################################################

############## 
# check array
function checkArray() {
if [[ ! -e ${FILENAME}.root ]] || [[ ! -s ${FILENAME}.root ]]; then
    FILESTATUS="FALSE"
    FFN=$(basename ${FILENAME}.root)
    DFN=$(dirname ${FILENAME}.root)
    echo "ERROR: effective area file ${FFN} missing in ${DFN}"
fi
}
function checkLogFile() {
if [[ -e ${FILENAME}.log ]]; then
    FILELOGSTATUS="FALSE"
    FFN=$(basename ${FILENAME}.log)
    DFN=$(dirname ${FILENAME}.log)
    echo "Error: effective area log file ${FFN} in ${DFN}"
fi
# SMALLFILE is not always working
if  [[ -e ${FILENAME}.SMALLFILE ]]; then
    LLOG=$($EVNDISPSYS/bin/logFile effAreaLog ${FILENAME}.root | grep -i error)
    if [[ -z ${LLOG} ]]; then
       echo "OLD SMALLFILE ${FILENAME}.SMALLFILE (removing)"
       rm -f ${FILENAME}.SMALLFILE
    else
       FILELOGSTATUS="FALSE"
       FFN=$(basename ${FILENAME}.SMALLFILE) 
       DFN=$(dirname ${FILENAME}.SMALLFILE)
       echo "Error: effective area small file ${FFN} in ${DFN}"
    fi
fi
}

##########################################################

# list of arrays
ALIST=$(cat $2)
for A in ${ALIST}
do
   echo "Layout $A"
   DDIR=${CTA_USER_DATA_DIR}/analysis/AnalysisData/${1}/${A}
   EFFDIR=${CTA_USER_DATA_DIR}/analysis/AnalysisData/${1}/EffectiveAreas/

   # recid
   for I in ${3}
   do
       if [[ ${4} == "MSCWTEST" ]]; then
         for MCAZ in "" _0deg _180deg
         do
             ADIR=${DDIR}/Analysis-ID${I}-${ANADATE}.EFFAREA.MCAZ${MCAZ}
             if [[ ! -d ${ADIR} ]]; then
                 echo "ERROR: directory with input data not found: ${ADIR}"
             fi
             # number of MSCW files
             for P in gamma_onSource gamma_cone proton electron 
             do
                 NF=$(ls -1 ${ADIR}/${P}*mscw.root | wc -l)
                 if [[ $NF == "0" ]]; then
                    echo "ERROR: zero files found for ${P} in ${ADIR}"
                 fi
             done
             NF=$(ls -1 ${ADIR}/*mscw.root | wc -l)
             echo "Info: number of mscw files for ${A}, ID${I}, $MCAZ: $NF"
         done
     fi

     #################################################
     # check output of effective area stage
     #for E in AngularResolution QualityCuts001CU BDT.50h-V3.${EFFDATE}
     #for E in BDT.${OBSTIME}-V3.${EFFDATE}
     #for E in AngularResolution
     #for E in QualityCuts001CU
     #for E in BDT.${OBSTIME}-V3.${EFFDATE}
     for E in BDT.30m-V3.${EFFDATE}
     do
         #################### 
         # multiplicity loop 
         # (tmp: only MST and SST implemented)
         for M in 2 3 4 5 6
         do
            for S in 2 3 4 5 6
            do
               # MST or SST only layouts
               if [[ ${A} == *"MSTs-MSTF" ]] || [[ ${A} == *"SSTs" ]]; then
                  if [[ "$S" != "$M" ]]; then
                      continue
                  fi
               fi

               echo "  testing ${E} ${M}MSTs ${S}SSTs (${E})"
               FILESTATUS="TRUE"
               FILELOGSTATUS="TRUE"
               # (will always rerun all AZ bins, even if only one is wrong)
               for MCAZ in "" _0deg _180deg
               do
                   NIMMIN=$(($M<$S ? $M : $S))
                   # NIM string
                   NIM="NIM${NIMMIN}LST${NIMMIN}MST${M}SST${S}SCMST${NIMMIN}"

                   ADIR=${EFFDIR}/EffectiveArea-${OBSTIME}-ID${I}${MCAZ}-${NIM}-${EFFDATE}-V3/${E}/
                   if [[ ! -d ${ADIR} ]]; then
                       echo "ERROR: directory with effarea data not found: ${ADIR}"
                       FILESTATUS="FALSE"
                       continue
                   fi
                   for P in gamma_onSource gamma_cone electron proton
                   do
                       if [[ ${E} == "AngularResolution" ]] && [[ ${P} != *"gamma"* ]]; then
                          continue
                       fi
                       FILENAME="${ADIR}/${P}.${A}_ID${I}.eff-0"
                       checkArray
                       checkLogFile

                       # off-axis files
                       if [[ ${P} != "gamma_onSource" ]]; then
                          for (( m = 0; m < NWBINS; m++ ))
                          do
                              FILENAME="${ADIR}/${P}.${A}_ID${I}.eff-${m}"
                              checkArray
                              checkLogFile
                          done
                       fi
                   done
               done
               if [[ ${FILELOGSTATUS} == "FALSE" ]] || [[ ${FILESTATUS} == "FALSE" ]]; then
                  if [[ ${E} == "AngularResolution" ]]; then
                     RMODE="ANGRES"
                  elif [[ ${E} == "QualityCuts001CU" ]]; then
                     RMODE="QC"
                  else
                     RMODE="CUTS"
                  fi
                  rm -f ../prod5/runlist.testRedo
                  echo "$A" > ../prod5/runlist.testRedo
                  echo "REDO ${A}"
                  cd ../
                  echo "RERUNNING ./CTA.runAnalysis.sh.testRedo prod5-S-sq08 ${RMODE} ${I} ${NIMMIN} ${M} ${S} ${NIMMIN}"
                  ./CTA.runAnalysis.sh.testRedo prod5-S-sq08 ${RMODE} ${I} ${NIMMIN} ${M} ${S} ${NIMMIN}
                  #./CTA.runAnalysis.sh.testRedo prod5-S-sq08 QC ${I} ${NIMMIN} ${M} ${S} ${NIMMIN}
                  #./CTA.runAnalysis.sh.testRedo prod5-S-sq08 TRAIN ${I} ${NIMMIN} ${M} ${S} ${NIMMIN}
                  cd ./testProduction
              fi
            done
         done 
     done
  done
done
