#!/bin/sh
# Produce pedestal files from NSB simulations using sim_telarray
#
# script prepared for prod5/prod6 simulations
#
# Change the two variables at the top:
#  SIM_TELARRAY_PATH: pointing towards your sim_telarray installation
#  SCRATCH: scratch space to save the output
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time
#  TELTYPES: list of telescope types
#  PROD: production

if [ $# -lt 1 ]; then
     echo "
./producePedestals.sh <production (e.g. PROD6)> <zenith angle (e.g. 20.0)> <moon opt (e.g., dark, half, full)>
    "
    exit
fi

PROD=${1}
[[ "$2" ]] && ZENITH=$2 || ZENITH="20.0"
ZE=${ZENITH%.*} # For the file names
echo "Zenith angle set to ${ZENITH}"
[[ "$3" ]] && MOONSET=$3 || MOONSET="dark"
if [[ ${MOONSET} == "dark" ]]; then
    MOONOPT=""
elif [[ ${MOONSET} == "full" ]]; then
    MOONOPT="-DFULLMOON"
elif [[ ${MOONSET} == "half" ]]; then
    MOONOPT="-DHALFMOON"
else
    echo "unknown moon option (use dark, half, full)"
    exit
fi
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`
[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

CDIR=$(pwd)
SIM_TELARRAY_PATH=$SIM_TELARRAY_PATH # Change this if you have your own sim_telarray and do not use the setupPackage.sh script
SCRATCH="."

if [[ $PROD == "PROD5" ]]; then
    TELTYPES=( LST MST-FlashCam MST-NectarCam SST )
else
    TELTYPES=( LST MST-FlashCam MST-NectarCam SST SCT MAGIC )
fi


for i in "${!TELTYPES[@]}"
do
    T="${TELTYPES[$i]}"

    for SITE in CTA_NORTH CTA_SOUTH
    do
        # dedicated scratch directory
        SCRATCH=./${PROD}/${SITE}-ze${ZE}deg-${MOONSET}
        mkdir -p ${SCRATCH}
        echo "Writing all data products to ${SCRATCH}"
        echo "(use this directory as input for all following analysis steps)"
        if [[ $T == "SST" ]] && [[ $SITE == "CTA_NORTH" ]]
        then
            continue
        fi
        if [[ $T == "MAGIC" ]] && [[ $SITE == "CTA_SOUTH" ]]
        then
            continue
        fi
        echo "Simulating $T for ${PROD} at $SITE"


        outputFile="${SCRATCH}/pedestals-${SITE}-${T}${MOON}-ze-${ZE}-1k"
        rm -f "${outputFile}" "${outputFile}.simtel.gz" "${outputFile}.log"

        if [[ $PROD == "PROD5" ]] && [[ $T == "SST" ]]; then
            CFG="${SIM_TELARRAY_PATH}/cfg/CTA/CTA-${PROD}-${T}.cfg"
        elif [[ $PROD == "PROD5" ]]; then
            CFG="${SIM_TELARRAY_PATH}/cfg/CTA/CTA-PROD4-${T}.cfg"
        else
            CFG="${SIM_TELARRAY_PATH}/cfg/CTA/CTA-${PROD}-${T}.cfg"
        fi

        INCLUDEOPT=""
        if [[ $T == "MAGIC" ]]; then
            CFG="${SIM_TELARRAY_PATH}/cfg/MAGIC/MAGIC1.cfg"
            INCLUDEOPT="-I${SIM_TELARRAY_PATH}/cfg/MAGIC"
        fi

        if [[ $PROD == "PROD5" ]]; then
            SITEOPT=""
            ALT="-C Altitude=2150"
            ATMO="-C atmospheric_transmission=atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat"
            TEL=""
        elif [[ $PROD == "PROD6" ]]; then
            SITEOPT="-D${SITE}"
            if [[ $SITE == "CTA_NORTH" ]]; then
                ALT="-C Altitude=2156"
                ATMO="-C atmospheric_transmission=atm_trans_2156_1_3_2_0_0_0.1_0.1.dat"
                TEL=""
                # North: LST1 is different - generate pedestals for 2/3/4 and use that also for LST1
                if [[ $T == "LST" ]]; then
                    TEL="-DLST2"
                fi
            else
                ALT="-C Altitude=2147"
                ATMO="-C atmospheric_transmission=atm_trans_2147_1_10_2_0_2147.dat"
                TEL=""
            fi
        fi

        ${SIM_TELARRAY_PATH}/bin/sim_telarray -c ${CFG} \
           -I${SIM_TELARRAY_PATH}/cfg/CTA -I${SIM_TELARRAY_PATH}/cfg/common \
           -I${SIM_TELARRAY_PATH}/cfg/hess ${INCLUDEOPT} ${SITEOPT} ${ALT} -C iobuf_maximum=1000000000 \
           ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 ${TEL} \
           ${ATMO} \
           -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180  \
           -C pedestal_events=1000 \
           -C output_file=${outputFile}.simtel.gz \
           ${CDIR}/dummy1.corsika.gz >& ${outputFile}.log

   done
done

# minor cleanup
mv -f telarray_rand.conf.used ${SCRATCH}/
rm -f ctsim.hdata
