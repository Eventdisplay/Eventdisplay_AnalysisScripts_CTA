#!/bin/sh
# pack files for public IRFs
#
# includes:
# - physics files
# - effective area files for different particle types
#
# several hard wired parameters:
# - data set
# - array list
# - physics / effective area dates
# - multiplicities for different observation times
#
#
set -e

#######################################
# user set parameters
EFFDATE="20210610"
# nominal NSB
NSB="NSB1x"
# NSB5x
NSB="NSB5x"

# CTA South
SITE="South"
SITE="North"
# DATATYPE
# DL3: phys files
# DL2: eff area files
DTYP="DL3"

# Zenith Angle
ZE="20deg 40deg 60deg"
# Observation Time
OBS="50h 5h 30m 100s"

#(end of user set parameters)
##############################################
# output data directory
ODIR=$(pwd)
# array list
if [[ ${SITE} == "South" ]]; then
ALIST=$(cat ./subArray.prod5.South-ax.list)
SLIST=$(cat ./subArray.prod5.South-ax-sub.list)
PLACE="Paranal"
else
ALIST=$(cat ./subArray.prod5.North-BL.list)
SLIST=$(cat ./subArray.prod5.North-BL-sub.list)
ALIST=$(cat ./subArray.prod5.North-D25.list)
SLIST=$(cat ./subArray.prod5.North-D25-sub.list)
PLACE="LaPalma"
fi

for Z in ${ZE}
do
    # data directory
    if [[ ${SITE} == "South" ]]; then
        DDIR="/lustre/fs22/group/cta/users/maierg/analysis/AnalysisData/prod5-Paranal-${Z}-sq10-LL/"
        DDIR="./"
    else
        DDIR="/lustre/fs22/group/cta/users/maierg/analysis/AnalysisData/prod5b-LaPalma-${Z}-sq10-LL/"
        DDIR="./"
    fi
    for O in ${OBS}
    do
        if [[ ${O} == "50h" ]] || [[ ${O} == "5h" ]] ; then
            # full arrays
            if [[ ${SITE} == "South" ]]; then
                M="NIM3LST3MST3SST4SCMST3"
            else
                M="NIM3LST3MST3SST3SCMST3"
            fi
            # sub arrays
            MS="NIM3LST3MST3SST3SCMST3"
        else
            M="NIM2LST2MST2SST2SCMST2"
            MS="NIM2LST2MST2SST2SCMST2"
        fi
        CDIR=$(pwd)

        TFIL="${ODIR}/IRFs-${DTYP}-${SITE}-${Z}-${O}-${NSB}.tar"
        rm -f ${TFIL}
        if [[ ${DTYP} == "DL2" ]]; then
            DLDIR="${DDIR}/EffectiveAreas/EffectiveArea-${O}-ID0-${M}-g${EFFDATE}-V3/BDT.${O}-V3.g${EFFDATE}"
            DLNAM="*${A}*root"
        else
            DLDIR="${DDIR}/Phys-g${EFFDATE}-${NSB}"
            if [[ ${O} == "50h" ]]; then
               T="180000s"
            elif [[ ${O} == "5h" ]]; then
               T="18000s"
            elif [[ ${O} == "30m" ]]; then
               T="1800s"
            elif [[ ${O} == "100s" ]]; then
               T="100s"
            fi
        fi
        cd ${DLDIR}
        rm -f ${TFIL}
        # full arrays
        for A in ${ALIST}
        do
           if [[ ${DTYP} == "DL2" ]]; then
               DLNAM="*${A}*root"
           else
               DLNAM="DESY.*${M}*${PLACE}*${Z}*${A}.${T}.root"
           fi
           tar -uvf ${TFIL} ${DLNAM} -C ${DLDIR}/
        done
        # sub arrays
        for A in ${SLIST}
        do
           if [[ ${DTYP} == "DL2" ]]; then
               DLNAM="*${A}*root"
           else
               if [[ ${A} != *"MSTs"* ]] && [[ ${A} != *"LSTs"* ]] && [[ ${O} != "30m" ]] && [[ ${O} != "100s" ]]; then
                   DLNAM="DESY.*NIM4LST4MST4SST4SCMST4*${PLACE}*${Z}*${A}.${T}.root"
               else
                   DLNAM="DESY.*${MS}*${PLACE}*${Z}*${A}.${T}.root"
               fi
           fi
           tar -uvf ${TFIL} ${DLNAM} -C ${DLDIR}/
        done
        # cleanup
        gzip -f -v ${TFIL}
        cd ${CDIR}
    done
done
