#!/bin/sh
# Produce pedestal files from NSB simulations using sim_telarray
#
# script prepared for prod5 simulations
#
# Change the two variables at the top:
#  SIMTEL: pointing towards your sim_telarray installation
#  SCRATCH: scratch space to save the output
#  MOONOPT: option to produce pedestals for halfmoon NSB or dark time

CDIR=$(pwd)
SIMTEL="USER_SET_SIM_TELARRAY"
SCRATCH="USER_SET_SCRATCH"

ZENITH="20.0"
# ZENITH="60.0"
ZE=${ZENITH%.*} # For the file names

echo "Zenith angle set to ${ZENITH}"

MOONOPT="" # Set to -DHALFMOON for half moon or leave empty or dark conditions (i.e., MOONOPT="")
MOON=`echo "${MOONOPT#*-D}" | tr "[:upper:]" "[:lower:]"`

[ -z "$MOON" ] && echo "Running dark conditions" || MOON="-${MOON}"


#####################################################################
# LST
#####################################################################

outputFile="${SCRATCH}/pedestals-lst${MOON}-ze-${ZE}-1k.simtel.gz"
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD4-LST.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${CDIR}/dummy1.corsika.gz >& sim_telarray${MOON}-lst-ze-${ZE}.log


#####################################################################
# MST-NectarCam
#####################################################################

outputFile="${SCRATCH}/pedestals-mst-nc${MOON}-ze-${ZE}-1k.simtel.gz"
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD4-MST-NectarCam.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${CDIR}/dummy1.corsika.gz >& sim_telarray${MOON}-mst-nc-ze-${ZE}.log


#####################################################################
# MST-FlashCam
#####################################################################

outputFile="${SCRATCH}/pedestals-mst-fc${MOON}-ze-${ZE}-1k.simtel.gz"
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD4-MST-FlashCam.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${CDIR}/dummy1.corsika.gz >& sim_telarray${MOON}-mst-fc-ze-${ZE}.log

#####################################################################
# SST
#####################################################################

outputFile="${SCRATCH}/pedestals-sst${MOON}-ze-${ZE}-1k.simtel.gz"
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD5-SST.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   ${MOONOPT} -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -DNSB_AUTOSCALE -C telescope_theta=${ZENITH} -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${CDIR}/dummy1.corsika.gz >& sim_telarray${MOON}-sst-ze-${ZE}.log
