
if [ $# -lt 3 ]; then
  echo "./runS-SV.sh <production> <run mode> <recID>"
  echo "   e.g., ./runS-SV.sh S20degSV1 TRAIN"
  exit
fi

PROD=${1}
NT=${2}
RECID="${3}"

echo "Running ${PROD} ${NT} ${RECID}"

if [[ ${PROD} == "S20degSV1" ]]; then
    for R in  ${RECID}
    do
        ./CTA.runAnalysis.sh ${PROD} ${NT} ${R} 1 1 2 2
        ./CTA.runAnalysis.sh ${PROD} ${NT} ${R} 1 1 3 3
        ./CTA.runAnalysis.sh ${PROD} ${NT} ${R} 1 1 4 4
    done
elif [[ ${PROD} == "S20degSV2" ]]; then
    for R in  ${RECID}
    do
        ./CTA.runAnalysis.sh ${PROD} ${NT} ${R} 2 2 2 2
        ./CTA.runAnalysis.sh ${PROD} ${NT} ${R} 2 2 3 3
        ./CTA.runAnalysis.sh ${PROD} ${NT} ${R} 2 2 4 4
    done
else
    for T in 4 3 2
    do
       for R in  ${RECID}
       do
           ./CTA.runAnalysis.sh ${PROD} $NT ${R} $T $T $T $T
       done
    done
fi
