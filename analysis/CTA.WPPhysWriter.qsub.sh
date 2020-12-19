#!/bin/bash
#
# script to write CTA WP Phys Files
#
#
#
#######################################################################

AXRRAY=ARRAY
DXDIR=DDIR
OXBSTIME=OBSTIME
OXUTNAME=OUTNAME
OXFFSET=OFFSET
RECID=RRRR
FBOFFAXIS=OFAXISFB

OBBIN=0
if [[ $FBOFFAXIS == "TRUE" ]]
then
  OBBIN=1
fi
echo "OFFAXIS FINE BINNING $OBBIN"

# set the right observatory (environmental variables)
source $EVNDISPSYS/setObservatory.sh CTA

rm -f $OXUTNAME.$AXRRAY.$OXBSTIME.log

echo $EVNDISPSYS
$EVNDISPSYS/bin/writeCTAWPPhysSensitivityFiles $AXRRAY $OXBSTIME $DXDIR $OXUTNAME CTA $OXFFSET $RECID $OBBIN > $OXUTNAME.$AXRRAY.$OXBSTIME.log

############################################################################

if [ -e $OXUTNAME.$AXRRAY.$OXBSTIME.log ]
then 
   DE=$(grep "error filling" $OXUTNAME.$AXRRAY.$OXBSTIME.log)
   DF=$(grep "error, cannot find effective area tree" $OXUTNAME.$AXRRAY.$OXBSTIME.log)
   if [[ -z ${DE} ]] && [[ -z ${DF} ]]; then
       bzip2 -f $OXUTNAME.$AXRRAY.$OXBSTIME.log
       # root file
       DROOT=$(cat $OXUTNAME.$AXRRAY.$OXBSTIME.log | grep grep "writing histograms" | awk '{print $4}')
       if [[ -e ${DROOT} ]]; then
           $EVNDISPSYS/bin/logFile IRFLog $OXUTNAME.$AXRRAY.$OXBSTIME.log
       fi
   fi
fi

exit
