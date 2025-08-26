#!/bin/bash
#
# remove PHYS files which are definitely empty
# e.g., LST4 for 2LST arrays
#
if [ ! -n "$1" ]
then
    echo "./removeUnreaseonablePhysFiles.sh <path>"
    echo
    echo
    exit
fi

if [[ ! -d "$1" ]]; then
  echo "Error, directory does not exist"
  exit
fi

OPTION="-print -delete"

# North SV arrays
find "$1" -name "*LST3MST*2LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM3LST3*2LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4*2LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4*3LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM3LST4*3LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4MST4*0LSTs03MSTs.*" ${OPTION}
find "$1" -name "*NIM4LST4MST4*3LSTs00MSTs.*" ${OPTION}
find "$1" -name "*NIM4LST4MST4*2LSTs00MSTs.*" ${OPTION}
find "$1" -name "*NIM3LST3MST3*2LSTs00MSTs.*" ${OPTION}
find "$1" -name "*MST3*0LSTs02MSTs-MSTN*" ${OPTION}
find "$1" -name "*MST4*0LSTs02MSTs-MSTN*" ${OPTION}
find "$1" -name "*MST4*0LSTs03MSTs-MSTN*" ${OPTION}
find "$1" -name "*LST4*2LSTs00MSTs-MSTN*" ${OPTION}
find "$1" -name "*LST4*2LSTs00MSTs-MSTN*" ${OPTION}
find "$1" -name "*MST4*LSTs03MSTs*" ${OPTION}


##################
# South LST arrays
# 4 LSTs
find "$1" -name "*NIM5LST5*4LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM6LST6*4LSTs00MSTs00SSTs-*" ${OPTION}
# 3 LSTs
find "$1" -name "*NIM5LST5*3LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM6LST6*3LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4*3LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4*S.BL-3LSTs[A-Z]*" ${OPTION}
# 2 LSTs
find "$1" -name "*NIM5LST5*2LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM6LST6*2LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4*2LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM3LST3*2LSTs00MSTs00SSTs-*" ${OPTION}
find "$1" -name "*NIM3LST3*S.BL-2LSTs[A-Z]*" ${OPTION}
find "$1" -name "*NIM4LST4*S.BL-2LSTs[A-Z]*" ${OPTION}
find "$1" -name "*NIM[3-9]LST*S-*2LSTs*" ${OPTION}
find "$1" -name "*NIM[4-9]LST*S-*3LSTs*" ${OPTION}
find "$1" -name "*NIM[5-9]LST*S-*4LSTs*" ${OPTION}
# 2LST 3 MSTs
find "$1" -name "*NIM3LST3MST3*2LSTs03MSTs*" ${OPTION}
find "$1" -name "*NIM4LST4MST4*2LSTs03MSTs*" ${OPTION}

# South SST arrays only
find "$1" -name "*ID2*-[0-9][0-9]SSTs.*" ${OPTION}

# South MST arrays only
find "$1" -name "*ID3*-[0-9][0-9]MSTs-MSTF*" ${OPTION}

# North LST arrays
find "$1" -name "*NIM4LST4*3LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM4LST4*2LSTs00MSTs-*" ${OPTION}
find "$1" -name "*NIM3LST3*2LSTs00MSTs-*" ${OPTION}
