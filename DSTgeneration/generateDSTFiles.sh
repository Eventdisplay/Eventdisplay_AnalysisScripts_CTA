#!/bin/sh
#
# generate DST files
#

# Sites:
SITE="Paranal"
SITE="LaPalma"

# Particle types:
TYPE="gamma_onSource"
TYPE="gamma_cone"

IPR="$EVNDISPSYS/../Eventdisplay_AnalysisFiles_CTA/Calibration/prod5/prod5-IPR.root"
ODIR="$CTA_USER_DATA_DIR/DST_testDevelopment_prod5/"

if [[ $SITE == "LaPalma" ]]; then
    MCDIR="/lustre/fs21/group/cta/prod5-grid/Prod5_LaPalma_AdvancedBaseline_NSB1x/"
    if [[ $TYPE == "gamma_onSource" ]]; then
        MCFILE="${MCDIR}/gamma_onSource/gamma_20deg_180deg_run100___cta-prod5-lapalma_desert-2158m-LaPalma-dark.simtel.zst"
    elif [[ $TYPE == "gamma_cone" ]]; then
        MCFILE="${MCDIR}/gamma_cone/gamma_20deg_180deg_run9974___cta-prod5-lapalma_desert-2158m-LaPalma-dark_cone10.simtel.zst"
    fi

    #######################
    # LSTs
    for N in "N.BL-4LSTs00MSTs-MSTF" "N.BL-3LSTs00MSTs-MSTF" "N.BL-2LSTs00MSTs-MSTF"
    do
        ARRAY="$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${N}.lis"

        # highE
        OFILE="${ODIR}/${N}-${TYPE}-Emin05TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -minenergy 5. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # lowE
        OFILE="${ODIR}/${N}-${TYPE}-Emax050GeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -maxenergy 0.05 -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # all energies
        OFILE="${ODIR}/${N}-${TYPE}-noEcut"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log
    done
    #######################
    # MSTs
    for N in "N.BL-0LSTs05MSTs-MSTF" "N.BL-0LSTs05MSTs-MSTN" "N.TF2-0LSTs05MSTs-MSTF" "N.TF2-0LSTs05MSTs-MSTN" "N.TA3-0LSTs05MSTs-MSTF" "N.TA3-0LSTs05MSTs-MSTN"
    do
        ARRAY="$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${N}.lis"

        # highE
        OFILE="${ODIR}/${N}-${TYPE}-Emin05TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -minenergy 5. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # lowE
        OFILE="${ODIR}/${N}-${TYPE}-Emax100GeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -maxenergy 0.10 -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # all energies
        OFILE="${ODIR}/${N}-${TYPE}-noEcut"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log
    done
elif [[ $SITE == "Paranal" ]]; then
    MCDIR="/lustre/fs21/group/cta/prod5-grid/Prod5_Paranal_AdvancedBaseline_NSB1x/"
    if [[ $TYPE == "gamma_onSource" ]]; then
        MCFILE="${MCDIR}/gamma_onSource/gamma_20deg_180deg_run985___cta-prod5-paranal_desert-2147m-Paranal-dark.simtel.zst"
    elif [[ $TYPE == "gamma_cone" ]]; then
        MCFILE="${MCDIR}/gamma_cone/gamma_20deg_180deg_run9986___cta-prod5-paranal_desert-2147m-Paranal-dark_cone10.simtel.zst"
    fi
    #######################
    # LSTs
    for N in "S.BL-4LSTs00MSTs00SSTs-MSTF" "S.BL-3LSTs00MSTs00SSTs-MSTF" "S.BL-2LSTs00MSTs00SSTs-MSTF"
    do
        ARRAY="$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${N}.lis"

        # highE
        OFILE="${ODIR}/${N}-${TYPE}-Emin05TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -minenergy 5. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # lowE
        OFILE="${ODIR}/${N}-${TYPE}-Emax050GeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -maxenergy 0.05 -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # all energies
        OFILE="${ODIR}/${N}-${TYPE}-noEcut"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log
    done
    #######################
    # MSTs
    for N in "S.BL-0LSTs25MSTs00SSTs-MSTF" "S.BL-0LSTs25MSTs00SSTs-MSTN"  "S.BL-0LSTs15MSTs00SSTs-MSTF" "S.BL-0LSTs15MSTs00SSTs-MSTN"
    do
        ARRAY="$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${N}.lis"

        # highE
        OFILE="${ODIR}/${N}-${TYPE}-Emin05TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -minenergy 5. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # lowE
        OFILE="${ODIR}/${N}-${TYPE}-Emax100GeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -maxenergy 0.10 -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # all energies
        OFILE="${ODIR}/${N}-${TYPE}-noEcut"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log
   done
    #######################
    # SSTs
    for N in "S.BL-0LSTs00MSTs50SSTs-MSTF"
    do
        ARRAY="$CTA_EVNDISP_AUX_DIR/DetectorGeometry/CTA.prod5${N}.lis"

        # highE
        OFILE="${ODIR}/${N}-${TYPE}-Emin05TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -minenergy 5. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # superE
        OFILE="${ODIR}/${N}-${TYPE}-Emin20TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -minenergy 20. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # lowE
        OFILE="${ODIR}/${N}-${TYPE}-Emax01TeV"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -maxenergy 1. -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log

        # all energies
        OFILE="${ODIR}/${N}-${TYPE}-noEcut"
        $EVNDISPSYS/bin/CTA.convert_hessio_to_VDST -a ${ARRAY} -c ${IPR} -o ${OFILE}.root ${MCFILE} > ${OFILE}.log
   done
fi
