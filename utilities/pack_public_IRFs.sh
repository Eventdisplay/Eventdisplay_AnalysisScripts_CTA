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


EFFDATE="20210610"

##############################################
# CTA South
SITE="South"
SITE="North"
# output data directory
ODIR=$(pwd)
# array list
if [[ ${SITE} == "SOUTH" ]]; then
    ALIST=$(cat ../prod5/subArray.prod5.South-ax.list)
    SLIST=$(cat ../prod5/subArray.prod5.South-ax-sub.list)
else
    ALIST=$(cat ../prod5/subArray.prod5.North-D25.list)
    SLIST=$(cat ../prod5/subArray.prod5.North-D25-sub.list)
fi

#for Z in 20deg
for Z in 20deg 40deg 60deg
do
    # data directory
    if [[ ${SITE} == "SOUTH" ]]; then
        DDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/prod5-Paranal-${Z}-sq10-LL/"
    else
        DDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/prod5b-LaPalma-${Z}-sq10-LL/"
    fi
    for O in 50h 5h 100s 30m
    do
        if [[ ${O} == "50h" ]] || [[ ${O} == "5h" ]] ; then
            # full arrays 
            if [[ ${SITE} == "SOUTH" ]]; then
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
        # DL3: phys files
        # DL2: eff area files
        for I in DL3
        do
           TFIL="${ODIR}/IRFs-${I}-${SITE}-${Z}-${O}.tar"
           rm -f ${TFIL}
           if [[ ${I} == "DL2" ]]; then
               DLDIR="${DDIR}/EffectiveAreas/EffectiveArea-${O}-ID0-${M}-g${EFFDATE}-V3/BDT.${O}-V3.g${EFFDATE}"
               DLNAM="*${A}*root"
           else
               DLDIR="${DDIR}/Phys-g${EFFDATE}"
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
               if [[ ${I} == "DL2" ]]; then
                   DLNAM="*${A}*root"
               else
                   DLNAM="DESY.*${M}*${A}.${T}.root"
               fi
               tar -uvf ${TFIL} ${DLNAM} -C ${DLDIR}/
           done
           # sub arrays
           for A in ${SLIST}
           do
               if [[ ${I} == "DL2" ]]; then
                   DLNAM="*${A}*root"
               else
                   DLNAM="DESY.*${MS}*${A}.${T}.root"
               fi
               tar -uvf ${TFIL} ${DLNAM} -C ${DLDIR}/
           done
           # cleanup
           gzip -f -v ${TFIL}
           cd ${CDIR}
        done
    done
done
