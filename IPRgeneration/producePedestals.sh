# Produce pedestal files from NSB simulations using sim_telarray
#
# script prepared for prod5 simulations
#
# Change the two variables at the top:
#  SIMTEL: pointing towards your sim_telarray installation
#  SCRATCH: scratch space to save the output

SIMEL='USER_SET_SIM_TELARRAY'
SCRATCH='USER_SET_SCRATCH'

#####################################################################
# LST
#####################################################################

outputFile='${SCRATCH}/pedestals-lst-1k.simtel.gz'
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD4-LST.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -C telescope_theta=20.0 -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${SCRATCH}/dummy1.corsika.gz >& sim_telarray-lst.log


#####################################################################
# MST-NectarCam
#####################################################################

outputFile='${SCRATCH}/pedestals-mst-nc-1k.simtel.gz'
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD4-MST-NectarCam.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -C telescope_theta=20.0 -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${SCRATCH}/dummy1.corsika.gz >& sim_telarray-mst-nc.log


#####################################################################
# MST-FlashCam
#####################################################################

outputFile='${SCRATCH}/pedestals-mst-fc-1k.simtel.gz'
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD4-MST-FlashCam.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -C telescope_theta=20.0 -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${SCRATCH}/dummy1.corsika.gz >& sim_telarray-mst-fc.log

#####################################################################
# SST
#####################################################################

outputFile='${SCRATCH}/pedestals-sst-1k.simtel.gz'
rm -f $outputFile

${SIMTEL}/bin/sim_telarray -c ${SIMTEL}/cfg/CTA/CTA-PROD5-SST.cfg \
   -Icfg/CTA -C Altitude=2150 -C iobuf_maximum=1000000000 \
   -DNUM_TELESCOPES=1 -C maximum_telescopes=1 \
   -C atmospheric_transmission=atm_trans_2150_1_10_0_0_2150.dat \
   -C telescope_theta=20.0 -C telescope_phi=180 \
   -C pedestal_events=1000 \
   -C output_file=$outputFile \
   ${SCRATCH}/dummy1.corsika.gz >& sim_telarray-sst.log
