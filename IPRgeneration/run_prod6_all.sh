#!/bin/sh
# Run analysis for all run modes, site, zenith angles and light levels
#

# for RUNMODE in producePedestals convertToDST produceIPRGraphs mergeIPRGraphs
for RUNMODE in convertToDST produceIPRGraphs mergeIPRGraphs
do
    for Z in 20.0 40.0 52.0 60.0
    do
        for M in dark half
        do
            ZE=${Z%.*}
            echo $RUNMODE $M $Z $ZE
            if [ "$RUNMODE" = "producePedestals" ]; then
                ./producePedestals.sh PROD6 "${Z}" "${M}" > "pedestals_${Z}_${M}.log" 2>&1
            else
                for SITE in CTA_NORTH CTA_SOUTH
                do
                    DATADIR="PROD6/${SITE}-ze${ZE}deg-${M}"
                    if [ "$RUNMODE" = "convertToDST" ]; then
                        ./convertToDST.sh "${DATADIR}" > "${DATADIR}/convert_${SITE}_${Z}_${M}.log" 2>&1
                    elif [ "$RUNMODE" = "produceIPRGraphs" ]; then
                        ./produceIPRGraphs.sh "${DATADIR}" > "${DATADIR}/ipr_${SITE}_${Z}_${M}.log" 2>&1
                    elif [ "$RUNMODE" = "mergeIPRGraphs" ]; then
                        if [ "$SITE" = "CTA_NORTH" ]; then
                            S="north"
                        else
                            S="south"
                        fi
                        ./mergeIPRGraphs.sh "${DATADIR}" "prod6-${S}-${M}-ze${ZE}deg-IPR.root"
                    fi
                done
            fi
        done
    done
done
