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
EFFDATE="20210610"

##############################################
# CTA South
SITE="South"
# output data directory
ODIR=$(pwd)
# array list
ALIST=$(cat ../prod5/subArray.prod5.South-a{x,x-sub}.list)

for Z in 20deg 40deg 60deg
do
    # data directory
    DDIR="$CTA_USER_DATA_DIR/analysis/AnalysisData/prod5-Paranal-${Z}-sq10-LL/"
    for O in 50h 5h 100s 30m
    do
        if [[ ${O} == "50h" ]] || [[ ${O} == "5h" ]] ; then
            M="NIM3LST3MST3SST4SCMST3"
        else
            M="NIM2LST2MST2SST2SCMST2"
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
           for A in ${ALIST}
           do
               if [[ ${I} == "DL2" ]]; then
                   DLNAM="*${A}*root"
               else
                   DLNAM="DESY.*${M}*${A}.${T}.root"
               fi
               tar -cvf ${TFIL} ${DLDIR}/${DLNAM} -C ${DLDIR}/
           done
           gzip -v ${TFIL}
           cd ${CDIR}
        done
    done
done
