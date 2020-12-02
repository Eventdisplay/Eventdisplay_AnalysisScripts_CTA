#!/bin/sh
#
# test EFFAREA results
#
# 2>| /dev/null


# disp training types
if [ $# -lt 3 ]
then
echo "
./test-CTA.EFFAREA.sh <data set> <list of layouts> <recid>

test results of effective area filling

"
exit
fi

##########################################################
# hardwired values
# analysis date
ANADATE="g20201021"
# effarea dates
EFFDATE="g20200817"
# NIM string
NIM="NIM3LST3MST3SST3SCMST3"
# observation time
OBSTIME="50h"
# Number of off-axis bins
NWBINS=5
# (end of) hardwired values
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

         #################################################
         # check output of effective area stage
         for E in AngularResolution QualityCuts001CU BDT.50h-V3.${EFFDATE}
         do
             ADIR=${EFFDIR}/EffectiveArea-${OBSTIME}-ID${I}${MCAZ}-${NIM}-${EFFDATE}-V3/${E}/
             if [[ ! -d ${ADIR} ]]; then
                 echo "ERROR: directory with effarea data not found: ${ADIR}"
                 continue
             fi
             for P in gamma_onSource gamma_cone electron proton
             do
                 if [[ ${E} == "AngularResolution" ]] && [[ ${P} != *"gamma"* ]]; then
                    continue
                 fi
                 # onSource files
                 if [[ ! -e ${ADIR}/${P}.${A}_ID${I}.eff-0.root ]] || [[ ! -s ${ADIR}/${P}.${A}_ID${I}.eff-0.root ]]; then
                     echo "ERROR: effective area file ${P}.${A}_ID${I}.eff-0.root missing in ${ADIR}"
                 fi
                 # off-axis files
                 if [[ ${P} != "gamma_onSource" ]]; then
                     for (( m = 0; m < NWBINS; m++ ))
                     do
                         if [[ ! -e ${ADIR}/${P}.${A}_ID${I}.eff-${m}.root ]] || [[ ! -s ${ADIR}/${P}.${A}_ID${I}.eff-0.root ]]; then
                             echo "ERROR: effective area file ${P}.${A}_ID${I}.eff-${m}.root missing in ${ADIR}"
                         fi
                     done
                 fi
             done 
         done
      done
   done
done

