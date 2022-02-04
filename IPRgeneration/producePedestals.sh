#!/bin/sh
# Produce pedestal files from NSB simulations using sim_telarray
#
# script prepared for prod5 simulations
#
# Change the two variables at the top:
#  SIMTEL: pointing towards your sim_telarray installation
#  SCRATCH: scratch space to save the output
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time
#  TELTYPES: list of telescope types
#  PROD: production

CDIR=$(pwd)
SIMTEL="/cvmfs/cta.in2p3.fr/software/centos7/gcc83_noOpt/simulations/corsika_simtelarray/2020-06-29b/sim_telarray"
SCRATCH="/lustre/fs22/group/cta/users/maierg/analysis/AnalysisData/prod5-ParanalSST-sq20-LL/"

ZENITH="20.0"
# ZENITH="60.0"
ZE=${ZENITH%.*} # For the file names

echo "Zenith angle set to ${ZENITH}"

MOONOPT="" # Set to -DHALFMOON for half moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"

TELTYPES=( LST MST-FlashCam MST-NectarCam SST )
TELTYPES=( SST )
PROD="PROD4"
PROD="PROD5"

for T in $TELTYPES
do
    echo "Simulating $T"

    outputFile="${SCRATCH}/pedestals-${T}${MOON}-ze-${ZE}-1k.simtel.gz"
    rm -f $outputFile

    CFG="${SIMTEL}/cfg/CTA/CTA-${PROD}-${T}.cfg"

    ${SIMTEL}/bin/sim_telarray -c ${CFG} \
       -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
       ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
       -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
       -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180 \
       -C pedestal_events=1000 \
       -C output_file=$outputFile \
       ${CDIR}/dummy1.corsika.gz >& sim_telarray${MOON}-${T}-ze-${ZE}.log

done
