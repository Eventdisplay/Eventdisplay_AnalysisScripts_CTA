# script to extract certain telescope combinations
# from large telescope lists
#
# hardwired: 
# - OF: output file
# - IF: input (large) list
# - list of MSTs and SST


OF="subArray.prod5.South-Opt-Top4.list"

IF="subArray.prod5.South-Opt-13MSTs30SSTs.list"
IF="subArray.prod5.South-Opt-13MSTs40SSTs.list"

IF="subArray.prod5.South-Opt-15MSTs40SSTs.list"
IF="subArray.prod5.South-Opt-15MSTs30SSTs.list"

#for M in M3 M1
for M in M3 M5
do
  for S in C3 C5 D1a C1
  do
     grep "${M}${S}-" ${IF}
  done
done
