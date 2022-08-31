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

CDIR=$(pwd)
SIM_TELARRAY_PATH=$SIM_TELARRAY_PATH # Change this if you have your own sim_telarray and do not use the setupPackage.sh script
SCRATCH="."

ZENITH="20.0"
# ZENITH="60.0"
ZE=${ZENITH%.*} # For the file names

echo "Zenith angle set to ${ZENITH}"

MOONOPT="" # Set to -DHALFMOON for half moon, -DFULLMOON for full moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

PROD="PROD4"
PROD="PROD5"
PROD="PROD6"

if [[ $PROD == "PROD5" ]]; then
    TELTYPES=( LST MST-FlashCam MST-NectarCam SST )
    TELTYPES=( SST )
else
    TELTYPES=( LST MST-FlashCam MST-NectarCam SST SCT MAGIC )
    SITE=( CTA_NORTH CTA_SOUTH CTA_NORTH CTA_SOUTH CTA_SOUTH CTA_NORTH )
fi

# dedicated scratch directory
SCRATCH=${SCRATCH}/${PROD}/ze-${ZE}${MOON}
mkdir -p ${SCRATCH}
echo "Writing all data products to ${SCRATCH}"
echo "(use this directory as input for all following analysis steps)"

for i in "${!TELTYPES[@]}"
do
    T="${TELTYPES[$i]}"
    echo "Simulating $T for ${PROD}"

    outputFile="${SCRATCH}/pedestals-${T}${MOON}-ze-${ZE}-1k.simtel.gz"
    rm -f $outputFile

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
    else
        SITEOPT="-D\"${SITE[$i]}\""
    fi

    ${SIM_TELARRAY_PATH}/bin/sim_telarray -c ${CFG} \
       -I${SIM_TELARRAY_PATH}/cfg/CTA -I${SIM_TELARRAY_PATH}/cfg/common \
       -I${SIM_TELARRAY_PATH}/cfg/hess ${INCLUDEOPT} ${SITEOPT} -C Altitude=2150 -C iobuf_maximum=1000000000 \
       ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
       -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
       -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180 \
       -C pedestal_events=1000 \
       -C output_file=$outputFile \
       ${CDIR}/dummy1.corsika.gz >& ${SCRATCH}/sim_telarray${MOON}-${T}-ze-${ZE}.log

    # minor cleanup
    mv -f telarray_rand.conf.used ${SCRATCH}/
    rm -f ctsim.hdata
done
